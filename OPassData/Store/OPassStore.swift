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
    @Published var event: EventStore?
    @Published var eventId: String?
    @Published var eventLogo: Image?

    private var eventTemporaryData: EventStore?
    private var keyStore = NSUbiquitousKeyValueStore()
    
    init() {
        keyStore.synchronize()
        if let data = keyStore.data(forKey: "EventStore") {
            do {
                let eventAPIData = try JSONDecoder().decode(EventStore.self, from: data)
                self.eventTemporaryData = eventAPIData
                self.eventId = eventAPIData.id
            } catch { logger.error("Unable to decode Event stored date: \(error.localizedDescription)") }
        } else { logger.info("No Event stored data was found") }
    }
}

extension OPassStore {
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
                    DispatchQueue.main.async {
                        self.event = event
                        Task{ await self.event!.loadLogos() }
                    }
                } else {
                    logger.info("Loading new event from \(self.event?.id ?? "none") to \(config.id)")
                    DispatchQueue.main.async {
                        self.event = .init(config)
                        Task{ await self.event!.loadLogos() }
                    }
                }
            } catch { // Use local data when it can't get data from API
                logger.notice("Can't get data from API. Using local data")
                if let eventAPIData = eventTemporaryData, eventAPIData.id == eventId {
                    DispatchQueue.main.async {
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
    
    func loginCurrentEvent(with token: String) async throws -> Bool {
        guard let eventId = self.eventId else { return false }
        do {
            if eventId == event?.id {
                return try await event?.redeem(token: token) ?? false
            }
            let config = try await APIManager.fetchConfig(for: eventId)
            let eventModel = EventStore(config)
            DispatchQueue.main.async {
                self.eventLogo = nil
                self.event = eventModel
            }
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
