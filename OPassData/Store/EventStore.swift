//
//  EventStore.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2025 OPass.
//

import OSLog
import PassKit
import SwiftUI
import SwiftDate
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
    private var walletPasses: [String: PKPass] = [:]
    private let keychain = Keychain(service: "token.app.opass.ccip").synchronizable(true)

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

    /// Return bool to indicate success or not
    @MainActor
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
            self.attendee = eventScenarioUseStatus
            Task{ await self.save() }
            return true
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch { return false }
    }

    /// Return bool to indicate token is valid or not. Will save token if is vaild.
    @MainActor
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

        let version = loginVersion
        do {
            let attendee = try await APIManager.fetchAttendee(from: feature, token: token)
            // Ignore the result if the user signed in or out while it was loading.
            guard loginVersion == version else { return false }
            loginVersion += 1
            self.attendee = attendee
            self.token = token
            self.userId = attendee.userId ?? "nil"
            self.userRole = attendee.role
            updatePushTopic(with: attendee)
            Task{ await self.save() }
            return true
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch { return false }
    }

    @MainActor
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
            if index == -1 {
                self.logoData = data
            } else {
                self.config.features[index].iconData = data
            }
        }
        Task{ await self.save() }
    }

    @MainActor
    func loadAttendee() async throws {
        guard let feature = config.feature(.fastpass) else {
            logger.critical("Can't find correct fastpass feature")
            throw Error.incorrectFeature
        }
        guard let token = token else {
            logger.error("No token included")
            throw Error.noTokenFound
        }

        let version = loginVersion
        do {
            let attendee = try await APIManager.fetchAttendee(from: feature, token: token)
            // Ignore the response if the user signed out, signed in again, or got another token from iCloud meanwhile.
            guard self.token == token, loginVersion == version else { return }
            self.attendee = attendee
            self.userId = attendee.userId ?? "nil"
            self.userRole = attendee.role
            updatePushTopic(with: attendee)
            Task{ await self.save() }
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch {
            guard self.token == token, loginVersion == version else { return }
            // Only an explicit rejection ends the push subscription; being offline or a server error keeps it.
            if case APIManager.LoadError.invalidToken = error {
                PushTopicManager.shared.setRole(nil, for: id)
            }
            // Cached data is shown, but never counts as a verified login.
            guard let data = self.eventAPITmpData, let attendee = data.attendee else {
                throw error
            }
            self.eventAPITmpData?.attendee = nil
            self.userId = attendee.userId ?? "nil"
            self.userRole = attendee.role
            self.attendee = attendee
        }
    }

    /// The ticket as an Apple Wallet pass, or nil when this device can't add passes
    /// or the wallet service doesn't issue one for this event.
    @MainActor
    func loadWalletPass() async -> PKPass? {
        guard let token, config.feature(.fastpass) != nil, PKAddPassesViewController.canAddPasses() else { return nil }
        if let pass = walletPasses[token] { return pass }
        do {
            let data = try await APIManager.fetchWalletPass(eventId: id, token: token)
            let pass = try PKPass(data: data)
            walletPasses[token] = pass
            return pass
        } catch {
            logger.error("Load wallet pass faild: \(error.localizedDescription)")
            return nil
        }
    }

    /// Re-verifies a stored token, which may come from iCloud Keychain or a restored backup,
    /// so this installation subscribes to the event's push topic only once the event service confirms it.
    @MainActor
    func verifyLogin() async {
        guard token != nil else { return }
        try? await loadAttendee()
    }

    @MainActor
    func loadSchedule(reload: Bool = false) async throws {
        guard let feature = config.feature(.schedule) else {
            logger.critical("Can't find correct schedule feature")
            throw Error.incorrectFeature
        }
        do {
            let schedule = try await APIManager.fetchSchedule(
                from: feature,
                reload: reload)
            self.schedule = schedule
            Task { await self.save() }
        } catch {
            guard let schedule = self.eventAPITmpData?.schedule else {
                throw error
            }
            self.eventAPITmpData?.schedule = nil
            self.schedule = schedule
        }
    }

    @MainActor
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
            self.announcements = announcements
            Task{ await self.save() }
        } catch  APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch {
            guard let announcements = self.eventAPITmpData?.announcements else {
                throw error
            }
            self.eventAPITmpData?.announcements = nil
            self.announcements = announcements
        }
    }

    @inline(__always)
    func notify(session: Session) {
        let notificationCenter = UNUserNotificationCenter.current()
        if likedSessions.contains(session.id) {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [session.id])
        } else {
            let content = UNMutableNotificationContent()
            content.title = String(localized: "Session will start in 5 mins.")
            content.body = String(
                format: String(localized: "\"%@\" in room \"%@\", please keep your time of buffer to reach the room."),
                session.localized().title,
                schedule?.rooms[session.room]?.localized().name ?? "")
            content.sound = .default
            let date = (session.start - 5.minutes).dateComponents
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

    @MainActor
    func signOut() {
        loginVersion += 1
        PushTopicManager.shared.setRole(nil, for: id)
        walletPasses.removeAll()
        if attendee != nil {
            self.attendee = nil
            self.userId = "nil"
            self.userRole = "nil"
        }
        self.token = nil
    }

    /// Subscribes to the event's push topic with the role the event service just verified.
    @MainActor
    private func updatePushTopic(with attendee: Attendee) {
        guard attendee.eventId == id else {
            logger.warning("Attendee belongs to \(attendee.eventId) instead of \(self.id), push topic unchanged")
            return
        }
        PushTopicManager.shared.setRole(attendee.role, for: id)
    }

    /// Bumped on every sign-in and sign-out, and shared by all `EventStore` instances of the same event,
    /// so a response that belongs to an earlier login is never applied.
    @MainActor private static var loginVersions: [String: Int] = [:]

    @MainActor private var loginVersion: Int {
        get { Self.loginVersions[id, default: 0] }
        set { Self.loginVersions[id] = newValue }
    }

    private func save() async {
        do {
            try EventCache.shared.save(self)
            logger.info("Save scuess of id: \(self.id)")
        } catch {
            logger.error("Save faild with: \(error.localizedDescription), id: \(self.id)")
        }
    }
}
