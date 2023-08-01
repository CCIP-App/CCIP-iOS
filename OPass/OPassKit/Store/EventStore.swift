//
//  EventStore.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2023 OPass.
//

import SwiftUI
import KeychainAccess
import OSLog

private let logger = Logger(subsystem: "OPassKit", category: "EventStore")

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

    private var eventAPITmpData: CodableEventService? = nil
    private let keychain = Keychain(service: "app.opass.ccip-token").synchronizable(true) //TODO: Change keychain id to "token.app.opass.ccip" after PyCon 23
    private let keyStore = NSUbiquitousKeyValueStore()
    
    init(
        _ config: EventConfig,
        logoData: Data? = nil,
        saveData: @escaping () async -> Void = {},
        tmpData: CodableEventService? = nil
    ) {
        id = config.id
        self.logoData = logoData
        self.config = config
        save = saveData
        _userId = AppStorage(wrappedValue: "nil", "userId", store: .init(suiteName: config.id))
        _userRole = AppStorage(wrappedValue: "nil", "userRole", store: .init(suiteName: config.id))
        _likedSessions = AppStorage(wrappedValue: [], "likedSessions", store: .init(suiteName: config.id))
        eventAPITmpData = tmpData
    }

    var save: () async -> Void
    var logo: Image? { logoData?.image() }
    var user_token: String? {
        get { try? keychain.get("\(self.id)_token") }
        set {
            if let user_token = newValue {
                do { try keychain.set(user_token, key: "\(self.id)_token") }
                catch { logger.error("Save user_token faild: \(error.localizedDescription)") }
            } else {
                do { try keychain.remove("\(self.id)_token") }
                catch { logger.error("Token remove error: \(error.localizedDescription)") }
            }
            objectWillChange.send()
        }
    }
    
    enum EventAPIError: Error {
        case noTokenFound
        case uncorrectFeature
    }

    private enum CodingKeys: String, CodingKey {
        case id, logoData, config, schedule, announcements, attendee
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        logoData = try container.decode(Data?.self, forKey: .logoData)
        let config = try container.decode(EventConfig.self, forKey: .config)
        self.config = config
        schedule = try container.decode(Schedule?.self, forKey: .schedule)
        announcements = try container.decode([Announcement]?.self, forKey: .announcements)
        attendee = try container.decode(Attendee?.self, forKey: .attendee)
        _userId = AppStorage(wrappedValue: "nil", "userId", store: .init(suiteName: config.id))
        _userRole = AppStorage(wrappedValue: "nil", "userRole", store: .init(suiteName: config.id))
        _likedSessions = AppStorage(wrappedValue: [], "likedSessions", store: .init(suiteName: config.id))
        save = {}
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(logoData, forKey: .logoData)
        try container.encode(config, forKey: .config)
        try container.encode(schedule, forKey: .schedule)
        try container.encode(announcements, forKey: .announcements)
        try container.encode(attendee, forKey: .attendee)
    }
}

extension EventStore {
    ///Return bool to indicate success or not
    func useScenario(scenario: String) async throws -> Bool{
        @Extract(.fastpass, in: config) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        guard let token = user_token else {
            logger.error("No user_token included")
            return false
        }
        
        do {
            let eventScenarioUseStatus = try await APIManager.fetchStatus(from: fastpassFeature, token: token, scenario: scenario)
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
    func redeemToken(token: String) async throws -> Bool {
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
            .alphanumerics
            .union(CharacterSet(charactersIn: "-_"))
            .inverted
        guard token.isNotEmpty, token.rangeOfCharacter(from: nonAllowedCharacters) == nil else {
            logger.info("Invalid user_token of \(token)")
            return false
        }
        
        @Extract(.fastpass, in: config) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        
        do {
            let attendee = try await APIManager.fetchStatus(from: fastpassFeature, token: token)
            Constants.sendTag("\(attendee.eventId)\(attendee.role)", value: "\(attendee.token)")
            DispatchQueue.main.async {
                self.attendee = attendee
                self.user_token = token
                self.userId = attendee.userId ?? "nil"
                self.userRole = attendee.role
                Task{ await self.save() }
            }
            return true
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch { return false }
    }
    
    func loadScenarioStatus() async throws {
        @Extract(.fastpass, in: config) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            throw EventAPIError.uncorrectFeature
        }
        guard let token = user_token else {
            logger.error("No user_token included")
            throw EventAPIError.noTokenFound
        }
        
        do {
            let attendee = try await APIManager.fetchStatus(from: fastpassFeature, token: token)
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
    
    func loadSchedule() async throws {
        @Extract(.schedule, in: config) var scheduleFeature
        
        guard let scheduleFeature = scheduleFeature else {
            logger.critical("Can't find correct schedule feature")
            throw EventAPIError.uncorrectFeature
        }
        do {
            let schedule = try await APIManager.fetchSchedule(from: scheduleFeature)
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
    
    func loadAnnouncements() async throws {
        @Extract(.announcement, in: config) var announcementFeature
        
        guard let announcementFeature = announcementFeature else {
            logger.critical("Can't find correct announcement feature")
            throw EventAPIError.uncorrectFeature
        }
        do {
            let announcements = try await APIManager.fetchAnnouncement(from: announcementFeature, token: user_token)
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
    
    func signOut() {
        if let attendee = attendee {
            Constants.sendTag("\(attendee.eventId)\(attendee.role)", value: "")
            self.attendee = nil
            self.userId = "nil"
            self.userRole = "nil"
        }
        self.user_token = nil
    }
}



// MARK: - Codable EventStore
class CodableEventService: Codable {
    init(id: String,
         settings: EventConfig,
         logoData: Data?,
         schedule: Schedule?,
         announcements: [Announcement]?,
         attendee: Attendee?) {
        self.id = id
        self.settings = settings
        self.logoData = logoData
        self.schedule = schedule
        self.announcements = announcements
        self.attendee = attendee
    }
    
    var id: String
    var settings: EventConfig
    var logoData: Data?
    var schedule: Schedule?
    var announcements: [Announcement]?
    var attendee: Attendee?
}
