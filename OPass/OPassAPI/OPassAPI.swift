//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

class OPassAPIModels: ObservableObject {
    
    @Published var eventLogo = Data()
    @Published var eventList = [EventModel]()
    @Published var eventSettings = EventSettingsModel()
    
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
    func loadEventSettings_Logo(event_id: String) async {
        //Settings
        guard let SettingsUrl = URL(string: "https://portal.opass.app/events/\(event_id)") else {
            print("Invalid EventDetail URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: SettingsUrl)
            
            let decodedResponse = try JSONDecoder().decode(EventSettingsModel.self, from: data)
            
            DispatchQueue.main.async {
                self.eventSettings = decodedResponse
            }
        } catch {
            print("EventSettingsDataError")
        }
        //Logo
        guard let logoUrl = URL(string: self.eventSettings.logo_url) else {
            print("Invalid Sessions PNG URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: logoUrl)
            
            DispatchQueue.main.async {
                self.eventLogo = data
            }
        } catch {
            print("EventLogoError")
        }
    }
    
    private func saveLocalData(dataObject: Data, filename: String) throws -> Bool {
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
    private func loadLocalData(filename: String) throws -> Data? {
        do {
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = url.appendingPathComponent(filename)
                let data = try Data(contentsOf: fileURL)
                return data
            }
            return nil
        } catch {
            return nil
        }
    }
}
