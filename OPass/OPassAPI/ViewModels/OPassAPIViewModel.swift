//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import Foundation
import OSLog

//Endpoint hold by OPass Official.
class OPassAPIViewModel: ObservableObject {
    
    @Published var eventList = [EventTitleModel]()
    @Published var currentEventID: String? = nil
    @Published var currentEventAPI: EventAPIViewModel? = nil
    private var eventAPITemporaryData: CodableEventAPIVM? = nil
    private var keyStore = NSUbiquitousKeyValueStore()
    private let logger = Logger(subsystem: "app.opass.ccip", category: "OPassAPI")
    
    init() {
        keyStore.synchronize()
        if let data = keyStore.data(forKey: "EventAPI") {
            do {
                let eventAPIData = try JSONDecoder().decode(CodableEventAPIVM.self, from: data)
                self.eventAPITemporaryData = eventAPIData
                self.currentEventID = eventAPIData.event_id
            } catch {
                logger.error("Unable to decode EventAPI \(error.localizedDescription)")
            }
        } else {
            logger.info("No EventAPI data found")
        }
    }
    
    func saveEventAPIData() async {
        logger.info("Saving data")
        if let eventAPI = self.currentEventAPI {
            do {
                let data = try JSONEncoder().encode(CodableEventAPIVM(
                    event_id: eventAPI.event_id,
                    display_name: eventAPI.display_name,
                    logo_url: eventAPI.logo_url,
                    eventSettings: eventAPI.eventSettings,
                    eventLogo: eventAPI.eventLogo,
                    eventSchedule: eventAPI.eventSchedule,
                    eventAnnouncements: eventAPI.eventAnnouncements,
                    eventScenarioStatus: eventAPI.eventScenarioStatus,
                    isLogin: eventAPI.isLogin))
                keyStore.set(data, forKey: "EventAPI")
                logger.info("Save scuess of id: \(eventAPI.event_id)")
            } catch {
                logger.error("Save eventAPI data \(error.localizedDescription)")
            }
        } else {
            logger.notice("No data found, bypass for saving EventAPIData")
        }
    }
    
    func loadEventList() async throws {
        logger.info("Loading eventList")
        let eventList = try await APIRepo.loadEventList()
        DispatchQueue.main.async {
            self.eventList = eventList
        }
    }
    
    func loadCurrentEventAPI() async {
        if let eventID = currentEventID {
            if let eventId = currentEventID, let eventSettings = try? await APIRepo.loadEventSettings(id: eventId) {
                if let eventAPIData = eventAPITemporaryData, eventID == eventAPIData.event_id { //Reload
                    let event = EventAPIViewModel(
                        eventSettings: eventSettings,
                        eventLogo: eventAPIData.eventLogo,
                        eventSchedule: eventAPIData.eventSchedule,
                        eventAnnouncements: eventAPIData.eventAnnouncements,
                        eventScenarioStatus: eventAPIData.eventScenarioStatus,
                        isLogin: eventAPIData.isLogin,
                        saveData: self.saveEventAPIData)
                    logger.info("Reload event \(event.event_id)")
                    DispatchQueue.main.async {
                        self.currentEventAPI = event
                        Task{ await self.currentEventAPI!.loadLogos() }
                    }
                } else { //Load new
                    let event = EventAPIViewModel(eventSettings: eventSettings, saveData: self.saveEventAPIData)
                    logger.info("Loading new event from \(self.currentEventAPI?.event_id ?? "none") to \(event.event_id)")
                    DispatchQueue.main.async {
                        self.currentEventAPI = event
                        Task{ await self.currentEventAPI!.loadLogos() }
                    }
                }
            } else { //Use local data when it can't get data from API
                logger.notice("Can't get data from API. Using local data")
                if let eventAPIData = eventAPITemporaryData {
                    DispatchQueue.main.async {
                        self.currentEventAPI = EventAPIViewModel(
                            eventSettings: eventAPIData.eventSettings,
                            eventLogo: eventAPIData.eventLogo,
                            eventSchedule: eventAPIData.eventSchedule,
                            eventAnnouncements: eventAPIData.eventAnnouncements,
                            eventScenarioStatus: eventAPIData.eventScenarioStatus,
                            isLogin: eventAPIData.isLogin,
                            saveData: self.saveEventAPIData)
                    }
                }
            }
            self.eventAPITemporaryData = nil //Clear temporary data
        }
    }
    
    func loginEvent(_ eventId: String, withToken token: String) async {
        do {
            let eventSettings = try await APIRepo.loadEventSettings(id: eventId)
            let eventModel = EventAPIViewModel(eventSettings: eventSettings, saveData: saveEventAPIData)
            DispatchQueue.main.async {
                self.currentEventAPI = eventModel
            }
            _ = await eventModel.redeemToken(token: token)
        } catch APIRepo.LoadError.invalidURL(url: let url) {
            logger.error("\(url.getString()) is invalid, eventId is possibly wrong")
        } catch APIRepo.LoadError.dataFetchingFailed(cause: let cause) {
            logger.error("Data fetch failed. \n Caused by: \(cause.localizedDescription)")
        } catch {
            logger.error("Error: \(error.localizedDescription)")
        }
    }
}
