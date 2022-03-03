//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

class OPassAPIModels: ObservableObject {
    
    @Published var eventList = [EventModel]()
    @Published var currentEvent: EventModel? = nil {
        willSet {
            if newValue?.eventSettings == nil {
                Task {
                    await newValue?.loadEventSettings_Logo()
                }
            }
        }
    }
    
    @Published var eventSettings = EventSettingsModel()
    @Published var eventSession = EventSessionModel()
    
    func loadEventList() async {
        guard let url = URL(string: "https://portal.opass.app/events/") else {
            print("Invalid EventList URL")
            return
        }
        
        do {
            let (urlData, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode([EventModel].self, from: urlData)
            
            DispatchQueue.main.async {
                self.eventList = decodedResponse
            }
        } catch {
            print("Invalid EventList Data From API")
        }
    }
    
    func loadEventSession() async {
        
        //Looking for better solution
        var session_url = ""
            
        if eventSettings.features[0].feature == .schedule {
            session_url = eventSettings.features[0].url!
        } else {
            session_url = eventSettings.features[1].url!
        }
        //End of it
        
        guard let url = URL(string: session_url) else {
            print("Invalid EventSession URL")
            DispatchQueue.main.async {
                self.eventSession = EventSessionModel()
            }
            return
        }
        do {
            let (urlData, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(EventSessionModel.self, from: urlData)
            
            DispatchQueue.main.async {
                self.eventSession = decodedResponse
            }
        } catch {
            DispatchQueue.main.async {
                self.eventSession = EventSessionModel()
            }
            print("Invalid EventSession Data From API")
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
