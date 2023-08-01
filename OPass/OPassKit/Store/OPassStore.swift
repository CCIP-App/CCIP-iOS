//
//  OPassStore.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2023 OPass.
//

import SwiftUI
import OSLog

private let logger = Logger(subsystem: "OPassKit", category: "OPassStore")

class OPassStore: ObservableObject {
    @Published var event: EventStore?
    @Published var eventId: String?
    @Published var eventLogo: Image?

    private var eventTemporaryData: CodableEventService?
    private var keyStore = NSUbiquitousKeyValueStore()
    
    init() {
        keyStore.synchronize()
        if let data = keyStore.data(forKey: "EventStore") {
            do {
                let eventAPIData = try JSONDecoder().decode(CodableEventService.self, from: data)
                self.eventTemporaryData = eventAPIData
                self.eventId = eventAPIData.id
            } catch { logger.error("Unable to decode Event stored date: \(error.localizedDescription)") }
        } else { logger.info("No Event stored data was found") }
    }
}

extension OPassStore {
    func save() async {
        logger.info("Saving data")
        if let EventStore = self.event {
            do {
                let data = try JSONEncoder().encode(CodableEventService(
                    id: EventStore.id,
                    settings: EventStore.config,
                    logoData: EventStore.logoData,
                    schedule: EventStore.schedule,
                    announcements: EventStore.announcements,
                    attendee: EventStore.attendee
                ))
                keyStore.set(data, forKey: "EventAPI")
                logger.info("Save scuess of id: \(EventStore.id)")
            } catch {
                logger.error("Save EventStore data \(error.localizedDescription)")
            }
        } else {
            logger.notice("No data found, bypass for saving EventAPIData")
        }
    }
    
    func loadEvent() async throws {
        if let eventId = eventId {
            do {
                let settings = try await APIManager.fetchConfig(for: eventId)
                if let eventAPIData = eventTemporaryData, eventId == eventAPIData.id { // Reload
                    let event = EventStore(
                        settings,
                        logoData: eventAPIData.logoData,
                        saveData: self.save,
                        tmpData: eventAPIData)
                    logger.info("Reload event \(event.id)")
                    DispatchQueue.main.async {
                        self.event = event
                        Task{ await self.event!.loadLogos() }
                    }
                } else { // Load new
                    let event = EventStore(settings, saveData: self.save)
                    logger.info("Loading new event from \(self.event?.id ?? "none") to \(event.id)")
                    DispatchQueue.main.async {
                        self.event = event
                        Task{ await self.event!.loadLogos() }
                    }
                }
            } catch { // Use local data when it can't get data from API
                logger.notice("Can't get data from API. Using local data")
                if let eventAPIData = eventTemporaryData, eventAPIData.id == eventId {
                    DispatchQueue.main.async {
                        self.event = EventStore(
                            eventAPIData.settings,
                            logoData: eventAPIData.logoData,
                            saveData: self.save,
                            tmpData: eventAPIData)
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
                return try await event?.redeemToken(token: token) ?? false
            }
            let settings = try await APIManager.fetchConfig(for: eventId)
            let eventModel = EventStore(settings, saveData: save)
            DispatchQueue.main.async {
                self.eventLogo = nil
                self.event = eventModel
            }
            return try await eventModel.redeemToken(token: token)
        } catch APIManager.LoadError.forbidden {
            throw APIManager.LoadError.forbidden
        } catch APIManager.LoadError.invalidURL(url: let url) {
            logger.error("\(url.string) is invalid, eventId is possibly wrong")
        } catch APIManager.LoadError.fetchFaild(cause: let cause) {
            logger.error("Data fetch failed. \n Caused by: \(cause.localizedDescription)")
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
        return false
    }
}
