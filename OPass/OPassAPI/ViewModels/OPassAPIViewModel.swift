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
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "EventAPI") {
            do {
                let eventAPIData = try JSONDecoder().decode(CodableEventAPIVM.self, from: data)
                self.currentEventAPI = EventAPIViewModel(
                    eventSettings: eventAPIData.eventSettings,
                    eventLogo: eventAPIData.eventLogo,
                    eventSchedule: eventAPIData.eventSchedule,
                    eventAnnouncements: eventAPIData.eventAnnouncements,
                    eventScenarioStatus: eventAPIData.eventScenarioStatus,
                    isLogin: eventAPIData.isLogin,
                    saveData: {  })
            } catch {
                print("Unable to decode EventAPI \(error)")
            }
        } else {
            print("No EventAPI data found")
        }
    }
    
    func saveEventAPIData() async {
        print("123")
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
                print("Save scuess")
            } catch {
                print("Save eventAPI data \(error)")
            }
        } else {
            print("Because this is not taking object")
        }
    }
    
    func loadEventList() async {
        if let eventList = try? await APIRepo.loadEventList() {
            DispatchQueue.main.async {
                self.eventList = eventList
            }
        }
    }
    
    func loadCurrentEventAPI() async {
        if let eventId = currentEventID, let event = try? await APIRepo.loadEvent(id: eventId) {
            //let group = DispatchGroup()
            //group.enter()
            await event.loadLogos()
            DispatchQueue.main.async {
                self.currentEventAPI = event
                Task {
                    await self.saveEventAPIData()
                }
                //group.leave()
            }
            //group.notify(queue: .main) {
            //    Task {
            //        await saveEventAPIData()
            //    }
            //}
            print("Why this is not working")
            
        }
    }
    
    func loginEvent(_ eventId: String, withToken token: String) async {
        do {
            let eventModel = try await APIRepo.loadEvent(id: eventId)
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
    
    private func saveLocalData(dataObject: Data, filename: String) -> Bool {
        do {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = url.appendingPathComponent(filename)
                try dataObject.write(to: fileURL)
                return true
            }
            return false
        } catch {
            return false
        }
    }
    
    private func loadLocalData(filename: String) -> Data? {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = url.appendingPathComponent(filename)
        return try? Data(contentsOf: fileURL)
    }
}
