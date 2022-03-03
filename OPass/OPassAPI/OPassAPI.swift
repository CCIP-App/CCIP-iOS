//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

class OPassAPIViewModel: ObservableObject {
    
    @Published var eventList = [EventViewModel]()
    @Published var currentEvent: EventViewModel? = nil {
        willSet {
            if newValue?.eventSettings == nil {
                Task {
                    await newValue?.loadEventSettings_Logo()
                }
            }
        }
    }
    
    func loadEventList() async {
        guard let url = URL(string: "https://portal.opass.app/events/") else {
            print("Invalid EventList URL")
            return
        }
        
        do {
            let eventList: [EventViewModel] = try await URLSession.shared.jsonData(from: url)
            DispatchQueue.main.async {
                self.eventList = eventList
            }
        } catch {
            print("Invalid EventList Data From API")
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

extension URLSession {
    func jsonData<T: Decodable>(from url: URL) async throws -> T {
        let (data, _) = try await self.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
