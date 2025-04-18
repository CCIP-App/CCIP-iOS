//
//  OPassData.swift
//  OPassSwiftData
//
//  Created by Brian Chang on 2025/4/17.
//  2025 OPass.
//

import KeychainAccess
import OSLog
import OneSignalFramework
import SwiftData
import SwiftUI

private let logger = Logger(subsystem: "OPassSwiftData", category: "OPassData")

public class OPassData {
    public let modelContainer: ModelContainer
    public let modelContext: ModelContext

    @MainActor public static let shared = try! OPassData()

    private let keychain = Keychain(service: "token.app.opass.ccip").synchronizable(true)

    public init(inMemory: Bool = false) throws {
        let schema = Schema([
            Event.self,
            Feature.self

        ])

        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        let modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        self.modelContainer = modelContainer
        self.modelContext = .init(modelContainer)
    }

    enum Error: Swift.Error {
        case noTokenFound
        case invalidToken
        case incorrectFeature
    }

    public var token: String? {
        get {
            guard let event = try? fetchEvent() else { return nil }
            return try? keychain.get("\(event.id)_token")
        }
        set {
            guard let event = try? fetchEvent() else { return }
            if let token = newValue {
                do { try keychain.set(token, key: "\(event.id)_token") } catch {
                    logger.error("Save user token faild: \(error.localizedDescription)")
                }
            } else {
                do { try keychain.remove("\(event.id)_token") } catch {
                    logger.error("Token remove error: \(error.localizedDescription)")
                }
            }
        }
    }

    public func use(from feature: Feature, scenario: String) async throws {
        guard let token = token else {
            logger.error("No token included")
            throw Error.noTokenFound
        }
        let event = try fetchEvent()
        let attendee = try await APIManager.fetchAttendee(
            from: feature,
            token: token,
            scenario: scenario
        )
        event.attendee = attendee
        try modelContext.save()
    }

    public func redeem(from feature: Feature, token: String) async throws {
        let token = token.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let nonAllowedCharacters = CharacterSet
            .alphanumerics
            .union(CharacterSet(charactersIn: "-_"))
            .inverted
        guard !token.isEmpty, token.rangeOfCharacter(from: nonAllowedCharacters) == nil else {
            logger.info("Invalid token of \(token)")
            throw Error.invalidToken
        }
        
        let event = try fetchEvent()
        let attendee = try await APIManager.fetchAttendee(from: feature, token: token)
        
        OneSignal.User.addTag(
            key: "\(attendee.eventId)\(attendee.role)",
            value: "\(attendee.token)")
        
        event.attendee = attendee
        self.token = token
        event.userID = attendee.userId
        event.userRole = attendee.role
        try modelContext.save()
    }

    public func loadEvent(for eventID: String) async throws {
        let event = try await APIManager.fetchConfig(for: eventID)
        let oldEvent = try fetchEvent()
        modelContext.delete(oldEvent)
        modelContext.insert(event)
        try modelContext.save()
    }

    public func loadSchedule(
        from feature: Feature,
        reload: Bool = false
    ) async throws {
        let event = try fetchEvent()
        let schedule = try await APIManager.fetchSchedule(
            from: feature,
            reload: reload)
        event.schedule = schedule
        try modelContext.save()
    }

    public func loadAnnouncements(
        from feature: Feature,
        token: String? = nil,
        reload: Bool = false
    ) async throws {
        let event = try fetchEvent()
        let announcements = try await APIManager.fetchAnnouncements(
            from: feature,
            token: token,
            reload: reload)
        event.announcements = announcements
        try modelContext.save()
    }

    public func loadAttendee(
        from feature: Feature,
        reload: Bool = false
    ) async throws {
        guard let token = token else {
            logger.error("No token included")
            throw Error.noTokenFound
        }
        let event = try fetchEvent()
        let attendee = try await APIManager.fetchAttendee(
            from: feature,
            token: token,
            reload: reload
        )
        event.attendee = attendee
        try modelContext.save()
    }

    private func fetchEvent() throws -> Event {
        var fetchDescriptor = FetchDescriptor<Event>()
        fetchDescriptor.fetchLimit = 1
        return (try modelContext.fetch(fetchDescriptor))[0]
    }
}

extension View {
    public func opassDataContainer() -> some View {
        self.modelContainer(OPassData.shared.modelContainer)
    }
}
