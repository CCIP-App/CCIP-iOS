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
        didSet { if let event { UserDefaults.standard.set(event.id, forKey: "EventId") } }
    }
    @Published var eventId: String?
    @Published var eventLogo: Image?

    init() {
        let cachedEvent = EventCache.shared.load()
        eventId = UserDefaults.standard.string(forKey: "EventId") ?? cachedEvent?.id
        if let cachedEvent, cachedEvent.id == eventId { event = cachedEvent }
    }
}

extension OPassStore {
    /// Loads the selected event from the API.
    @MainActor
    func loadEvent(reload: Bool = false) async throws {
        guard let eventId else { return }
        let config = try await APIManager.fetchConfig(for: eventId, reload: reload)
        guard self.eventId == eventId else { return } // Skip if another event was selected meanwhile
        let event: EventStore
        if let current = self.event, current.id == eventId {
            logger.info("Refresh event \(eventId)")
            current.update(config)
            event = current
        } else {
            logger.info("Loading new event from \(self.event?.id ?? "none") to \(config.id)")
            event = EventStore(config)
            self.event = event
        }
        Task{ await event.loadLogos() }
        Task{ await event.verifyLogin() }
    }

    @MainActor
    func refreshEvent() async {
        guard let event, event.isStale else { return }
        do {
            try await loadEvent(reload: true)
        } catch {
            logger.notice("Can't refresh event from API, using cached data: \(error.localizedDescription)")
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
