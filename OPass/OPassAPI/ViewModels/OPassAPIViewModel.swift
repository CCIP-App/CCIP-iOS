//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//  2022 OPass.
//

import Foundation

//Endpoint hold by OPass Official.
class OPassAPIViewModel: ObservableObject {
    
    @Published var eventList = [EventTitleModel]()
    @Published var currentEventID: String? = nil
    @Published var currentEventAPI: EventAPIViewModel? = nil
    private var eventAPITemporaryData: CodableEventAPIVM? = nil
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "EventAPI") {
            do {
                let eventAPIData = try JSONDecoder().decode(CodableEventAPIVM.self, from: data)
                self.eventAPITemporaryData = eventAPIData
                self.currentEventID = eventAPIData.event_id
            } catch {
                print("Unable to decode EventAPI \(error)")
            }
        } else {
            print("No EventAPI data found")
        }
    }
    
    func saveEventAPIData() async {
        print("Saving data")
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
                UserDefaults.standard.set(data, forKey: "EventAPI")
                print("Save scuess of id: \(eventAPI.event_id)")
            } catch {
                print("Save eventAPI data \(error)")
            }
        } else {
            print("Save data error")
        }
    }
    
    func loadEventList() async {
        if let eventList = try? await APIRepo.loadEventList() {
            DispatchQueue.main.async {
                self.eventList = eventList
            }
        }
    }
    
    func loadCurrentEventAPI() async { //TODO: Very very ugly code.
        if let eventID = currentEventID {
            if let eventId = currentEventID, let eventSettings = try? await APIRepo.loadEventSettings(id: eventId) {
                if let eventAPIData = eventAPITemporaryData, eventID == eventAPIData.event_id { //Reload
                    let group = DispatchGroup()
                    group.enter()
                    let event = EventAPIViewModel(
                        eventSettings: eventSettings,
                        eventLogo: eventAPIData.eventLogo,
                        eventSchedule: eventAPIData.eventSchedule,
                        eventAnnouncements: eventAPIData.eventAnnouncements,
                        eventScenarioStatus: eventAPIData.eventScenarioStatus,
                        isLogin: eventAPIData.isLogin,
                        saveData: self.saveEventAPIData)
                    await event.loadLogos() //TODO: Will save old one and that is badddd.
                    DispatchQueue.main.async {
                        self.currentEventAPI = event
                        group.leave()
                    }
                    group.notify(queue: .main) {
                        Task { await self.saveEventAPIData() }
                    }
                    //Using this ugly code in order to make sure it run after
                    //currentEventAPI is set properly or it will save the old one.
                    //And I still had "One" time that will save the old one after the new one set.
                    //It mean the old one will exist in system.
                    //Test it about ten to twenty times.
                } else { //Load new
                    let group = DispatchGroup()
                    group.enter()
                    let event = EventAPIViewModel(eventSettings: eventSettings, saveData: self.saveEventAPIData)
                    await event.loadLogos() //TODO: Will save old one and that is badddd.
                    DispatchQueue.main.async {
                        self.currentEventAPI = event
                        group.leave()
                    }
                    group.notify(queue: .main) {
                        Task { await self.saveEventAPIData() }
                    }
                    //Using this ugly code in order to make sure it run after
                    //currentEventAPI is set properly or it will save the old one.
                    //And I still had "One" time that will save the old one after the new one set.
                    //It mean the old one will exist in system.
                    //Test it about ten to twenty times.
                }
            } else { //Use local data when it can't get data from API
                print("Can't get data from API. Using local data")
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
            print("\(url.getString()) is invalid")
            print("The eventId is possibly wrong")
        } catch APIRepo.LoadError.dataFetchingFailed(cause: let cause) {
            print("Data fetch failed. \n Caused by: \(cause)")
        } catch {
            print("Error: \(error)")
        }
    }
}
