//
//  OPassStore.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2025 OPass.
//

import OSLog
import SwiftUI

private let logger = Logger(subsystem: "OPassData", category: "OPassStore")

class OPassStore: ObservableObject {
    @Published var event: EventStore? {
        // Only the ID goes to iCloud, so the user's other devices open the same event.
        didSet { if let event { keyStore.set(event.id, forKey: "EventId") } }
    }
    @Published var eventId: String?
    @Published var eventLogo: Image?

    private var eventTemporaryData: EventStore?
    private var keyStore = NSUbiquitousKeyValueStore()

    init() {
        keyStore.synchronize()
        EventCache.shared.migrate(from: keyStore)
        eventTemporaryData = EventCache.shared.load()
        eventId = keyStore.string(forKey: "EventId") ?? eventTemporaryData?.id
    }
}

extension OPassStore {
    @MainActor
    func loadEvent(reload: Bool = false) async throws {
        if let eventId = eventId {
            do {
                let config = try await APIManager.fetchConfig(for: eventId, reload: reload)
                if let eventAPIData = eventTemporaryData, eventId == eventAPIData.id { // Reload
                    let event = EventStore(
                        config,
                        logoData: eventAPIData.logoData,
                        tmpData: eventAPIData)
                    logger.info("Reload event \(event.id)")
                    if self.eventId == eventId { // Skip if another event was selected meanwhile
                        self.event = event
                        Task{ await event.loadLogos() }
                        Task{ await event.verifyLogin() }
                    }
                } else {
                    logger.info("Loading new event from \(self.event?.id ?? "none") to \(config.id)")
                    if self.eventId == eventId { // Skip if another event was selected meanwhile
                        let event = EventStore(config)
                        self.event = event
                        Task{ await event.loadLogos() }
                        Task{ await event.verifyLogin() }
                    }
                }
            } catch { // Use local data when it can't get data from API
                logger.notice("Can't get data from API. Using local data")
                if let eventAPIData = eventTemporaryData, eventAPIData.id == eventId {
                    if self.eventId == eventId { // Skip if another event was selected meanwhile
                        self.event = EventStore(
                            eventAPIData.config,
                            logoData: eventAPIData.logoData,
                            tmpData: eventAPIData
                        )
                    }
                } else {
                    self.eventTemporaryData = nil
                    throw error
                }
            }
            self.eventTemporaryData = nil // Clear temporary data
        }
    }

    @MainActor
    func signinCurrentEvent(with token: String) async throws -> Bool {
        guard let eventId = self.eventId else { return false }
        do {
            if eventId == event?.id {
                return try await event!.redeem(token: token)
            }
            let config = try await APIManager.fetchConfig(for: eventId)
            let eventModel = EventStore(config)
            self.eventLogo = nil
            self.event = eventModel
            return try await eventModel.redeem(token: token)
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch APIManager.LoadError.invalidURL(url: let url) {
            logger.error("\(url.string) is invalid, eventId is possibly wrong")
        } catch APIManager.LoadError.fetchFaild(cause: let cause) {
            logger.error("Data fetch failed. \n Caused by: \(cause.localizedDescription)")
        } catch { logger.error("Error: \(error.localizedDescription)") }
        return false
    }
}
