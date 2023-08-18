//
//  EventStore.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2023 OPass.
//

import OSLog
import SwiftUI
import SwiftDate
import OneSignalFramework
import KeychainAccess
import UserNotifications

private let logger = Logger(subsystem: "OPassData", category: "EventStore")

class EventStore: ObservableObject, Codable, Identifiable {
    public let id: String

    @Published var logoData: Data?
    @Published var config: EventConfig
    @Published var attendee: Attendee?
    @Published var schedule: Schedule?
    @Published var announcements: [Announcement]?

    @AppStorage var userId: String
    @AppStorage var userRole: String
    @AppStorage var likedSessions: [String]

    private var eventAPITmpData: EventStore? = nil
    private let keychain = Keychain(service: "app.opass.ccip-token").synchronizable(true) //TODO: Change keychain id to "token.app.opass.ccip" after PyCon 23
    private let keyStore = NSUbiquitousKeyValueStore()
    
    init(
        _ config: EventConfig,
        logoData: Data? = nil,
        tmpData: EventStore? = nil
    ) {
        id = config.id
        self.logoData = logoData
        self.config = config
        _userId = AppStorage(wrappedValue: "nil", "userId", store: .init(suiteName: config.id))
        _userRole = AppStorage(wrappedValue: "nil", "userRole", store: .init(suiteName: config.id))
        _likedSessions = AppStorage(wrappedValue: [], "likedSessions", store: .init(suiteName: config.id))
        eventAPITmpData = tmpData
    }
    
    enum Error: Swift.Error {
        case noTokenFound
        case incorrectFeature
    }

    private enum CodingKeys: String, CodingKey {
        case id, logoData, config, attendee, schedule, announcements
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        logoData = try container.decode(Data?.self, forKey: .logoData)
        let config = try container.decode(EventConfig.self, forKey: .config)
        self.config = config
        attendee = try container.decode(Attendee?.self, forKey: .attendee)
        schedule = try container.decode(Schedule?.self, forKey: .schedule)
        announcements = try container.decode([Announcement]?.self, forKey: .announcements)
        _userId = AppStorage(wrappedValue: "nil", "userId", store: .init(suiteName: config.id))
        _userRole = AppStorage(wrappedValue: "nil", "userRole", store: .init(suiteName: config.id))
        _likedSessions = AppStorage(wrappedValue: [], "likedSessions", store: .init(suiteName: config.id))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(logoData, forKey: .logoData)
        try container.encode(config, forKey: .config)
        try container.encode(attendee, forKey: .attendee)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(announcements, forKey: .announcements)
    }
}

extension EventStore {
    @inline(__always)
    var logo: Image? { logoData?.image() }

    @inline(__always)
    var token: String? {
        get { try? keychain.get("\(self.id)_token") }
        set {
            if let token = newValue {
                do {
                    try keychain.set(token, key: "\(self.id)_token")
                } catch { logger.error("Save user token faild: \(error.localizedDescription)") }
            } else {
                do {
                    try keychain.remove("\(self.id)_token")
                } catch { logger.error("Token remove error: \(error.localizedDescription)") }
            }
            objectWillChange.send()
        }
    }

    @inline(__always)
    var avaliableFeatures: [Feature] {
        config.features.filter { feature in
            if feature.isWeb && feature.url(token: token, role: userRole) == nil { return false }
            if let visibleRoles = feature.visibleRoles {
                guard userRole != "nil" else { return false }
                return visibleRoles.contains(userRole)
            }
            return true
        }
    }

    ///Return bool to indicate success or not
    func use(scenario: String) async throws -> Bool{
        guard let feature = config.feature(.fastpass) else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        guard let token = token else {
            logger.error("No token included")
            return false
        }
        
        do {
            let eventScenarioUseStatus = try await APIManager.fetchAttendee(from: feature, token: token, scenario: scenario)
            DispatchQueue.main.async {
                self.attendee = eventScenarioUseStatus
                Task{ await self.save() }
            }
            return true
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch { return false }
    }
    
    ///Return bool to indicate token is valid or not. Will save token if is vaild.
    func redeem(token: String) async throws -> Bool {
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
            .alphanumerics
            .union(CharacterSet(charactersIn: "-_"))
            .inverted
        guard token.isNotEmpty, token.rangeOfCharacter(from: nonAllowedCharacters) == nil else {
            logger.info("Invalid token of \(token)")
            return false
        }
        guard let feature = config.feature(.fastpass) else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        
        do {
            let attendee = try await APIManager.fetchAttendee(from: feature, token: token)
            OneSignal.User.addTag(key: "\(attendee.eventId)\(attendee.role)", value: "\(attendee.token)")
            DispatchQueue.main.async {
                self.attendee = attendee
                self.token = token
                self.userId = attendee.userId ?? "nil"
                self.userRole = attendee.role
                Task{ await self.save() }
            }
            return true
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch { return false }
    }

    func loadLogos() async {
        //Load Event Logo
        let icons: [Int: Data] = await withTaskGroup(of: (Int, Data?).self) { group in
            let logo_url = config.logoUrl
            let webViewFeatureIndex = config.features.enumerated().filter({ $0.element.feature == .webview }).map { $0.offset }

            group.addTask { (-1, try? await APIManager.fetchData(from: logo_url)) }
            for index in webViewFeatureIndex {
                if let iconUrl = config.features[index].icon{
                    group.addTask { (index, try? await APIManager.fetchData(from: iconUrl)) }
                }
            }

            var indexToIcon: [Int: Data] = [:]
            for await (index, data) in group {
                if data != nil {
                    indexToIcon[index] = data
                }
            }
            return indexToIcon
        }

        for (index, data) in icons {
            DispatchQueue.main.async {
                if index == -1 {
                    self.logoData = data
                } else {
                    self.config.features[index].iconData = data
                }
            }
        }
        Task{ await self.save() }
    }
    
    func loadAttendee() async throws {
        guard let feature = config.feature(.fastpass) else {
            logger.critical("Can't find correct fastpass feature")
            throw Error.incorrectFeature
        }
        guard let token = token else {
            logger.error("No token included")
            throw Error.noTokenFound
        }

        do {
            let attendee = try await APIManager.fetchAttendee(from: feature, token: token)
            DispatchQueue.main.async {
                self.attendee = attendee
                self.userId = attendee.userId ?? "nil"
                self.userRole = attendee.role
                Task{ await self.save() }
            }
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch {
            guard let data = self.eventAPITmpData, let attendee = data.attendee else {
                throw error
            }
            self.eventAPITmpData?.attendee = nil
            DispatchQueue.main.async {
                self.userId = attendee.userId ?? "nil"
                self.userRole = attendee.role
                self.attendee = attendee
            }
        }
    }

    func loadSchedule(reload: Bool = false) async throws {
        guard let feature = config.feature(.schedule) else {
            logger.critical("Can't find correct schedule feature")
            throw Error.incorrectFeature
        }
        do {
            let schedule = try await APIManager.fetchSchedule(
                from: feature,
                reload: reload)
            DispatchQueue.main.async {
                self.schedule = schedule
                Task { await self.save() }
            }
        } catch {
            guard let schedule = self.eventAPITmpData?.schedule else {
                throw error
            }
            self.eventAPITmpData?.schedule = nil
            DispatchQueue.main.async {
                self.schedule = schedule
            }
        }
    }
    
    func loadAnnouncements(reload: Bool = false) async throws {
        guard let feature = config.feature(.announcement) else {
            logger.critical("Can't find correct announcement feature")
            throw Error.incorrectFeature
        }
        do {
            let announcements = try await APIManager.fetchAnnouncements(
                from: feature,
                token: token,
                reload: reload)
            DispatchQueue.main.async {
                self.announcements = announcements
                Task{ await self.save() }
            }
        } catch  APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch {
            guard let announcements = self.eventAPITmpData?.announcements else {
                throw error
            }
            self.eventAPITmpData?.announcements = nil
            DispatchQueue.main.async {
                self.announcements = announcements
            }
        }
    }

    @inline(__always)
    func notify(session: Session) {
        let notificationCenter = UNUserNotificationCenter.current()
        if likedSessions.contains(session.id) {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [session.id])
        } else {
            let content = UNMutableNotificationContent()
            content.title = String(localized: "SessionWillStartIn5Minutes")
            content.body = String(
                format: String(localized: "SessionWillStartIn5MinutesContent"),
                session.localized().title,
                schedule?.rooms[session.room]?.localized().name ?? "")
            content.sound = .default
            let time = session.start - 5.minutes
            var date = DateComponents()
            date.month = time.month
            date.day = time.day
            date.hour = time.hour
            date.minute = time.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            let request = UNNotificationRequest(identifier: session.id, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    logger.error("Faild to add notification due to \(error.localizedDescription)")
                } else {
                    logger.info("Success to add notification with id: \(session.id)")
                }
            }
        }
    }

    @inline(__always)
    func signOut() {
        if let attendee = attendee {
            OneSignal.User.addTag(key: "\(attendee.eventId)\(attendee.role)", value: "")
            self.attendee = nil
            self.userId = "nil"
            self.userRole = "nil"
        }
        self.token = nil
    }

    private func save() async {
        do {
            let data = try JSONEncoder().encode(self)
            keyStore.set(data, forKey: "EventStore")
            logger.info("Save scuess of id: \(self.id)")
        } catch {
            logger.error("Save faild with: \(error.localizedDescription), id: \(self.id)")
        }
    }
}
