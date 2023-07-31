//
//  OPassService.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2023 OPass.
//

import SwiftUI
import OSLog

private let logger = Logger(subsystem: "OPassKit", category: "OPassStore")

class OPassService: ObservableObject {
    @Published var event: EventService? = nil
    @Published var eventId: String? = nil
    @Published var eventLogo: Image? = nil

    private var eventAPITemporaryData: CodableEventService? = nil
    private var keyStore = NSUbiquitousKeyValueStore()
    
    init() {
        keyStore.synchronize()
        if let data = keyStore.data(forKey: "EventStore") {
            do {
                let eventAPIData = try JSONDecoder().decode(CodableEventService.self, from: data)
                self.eventAPITemporaryData = eventAPIData
                self.eventId = eventAPIData.event_id
            } catch { logger.error("Unable to decode Event stored date: \(error.localizedDescription)") }
        } else { logger.info("No Event stored data was found") }
    }
}

extension OPassService {
    func saveEventAPIData() async {
        logger.info("Saving data")
        if let EventService = self.event {
            do {
                let data = try JSONEncoder().encode(CodableEventService(
                    event_id: EventService.event_id,
                    display_name: EventService.display_name,
                    logo_url: EventService.logo_url,
                    settings: EventService.settings,
                    logo_data: EventService.logo_data,
                    schedule: EventService.schedule,
                    announcements: EventService.announcements,
                    scenario_status: EventService.scenario_status
                ))
                keyStore.set(data, forKey: "EventAPI")
                logger.info("Save scuess of id: \(EventService.event_id)")
            } catch {
                logger.error("Save EventService data \(error.localizedDescription)")
            }
        } else {
            logger.notice("No data found, bypass for saving EventAPIData")
        }
    }
    
    func loadEvent() async throws {
        if let eventId = eventId {
            do {
                let settings = try await APIManager.fetchConfig(for: eventId)
                if let eventAPIData = eventAPITemporaryData, eventId == eventAPIData.event_id { // Reload
                    let event = EventService(
                        settings,
                        logo_data: eventAPIData.logo_data,
                        saveData: self.saveEventAPIData,
                        tmpData: eventAPIData)
                    logger.info("Reload event \(event.event_id)")
                    DispatchQueue.main.async {
                        self.event = event
                        Task{ await self.event!.loadLogos() }
                    }
                } else { // Load new
                    let event = EventService(settings, saveData: self.saveEventAPIData)
                    logger.info("Loading new event from \(self.event?.event_id ?? "none") to \(event.event_id)")
                    DispatchQueue.main.async {
                        self.event = event
                        Task{ await self.event!.loadLogos() }
                    }
                }
            } catch { // Use local data when it can't get data from API
                logger.notice("Can't get data from API. Using local data")
                if let eventAPIData = eventAPITemporaryData, eventAPIData.event_id == eventId {
                    DispatchQueue.main.async {
                        self.event = EventService(
                            eventAPIData.settings,
                            logo_data: eventAPIData.logo_data,
                            saveData: self.saveEventAPIData,
                            tmpData: eventAPIData)
                    }
                } else {
                    self.eventAPITemporaryData = nil
                    throw error
                }
            }
            self.eventAPITemporaryData = nil // Clear temporary data
        }
    }
    
    func loginCurrentEvent(with token: String) async throws -> Bool {
        guard let eventId = self.eventId else { return false }
        do {
            if eventId == event?.event_id {
                return try await event?.redeemToken(token: token) ?? false
            }
            let settings = try await APIManager.fetchConfig(for: eventId)
            let eventModel = EventService(settings, saveData: saveEventAPIData)
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
