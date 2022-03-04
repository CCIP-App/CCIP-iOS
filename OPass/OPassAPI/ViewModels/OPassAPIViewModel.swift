//
//  OPassAPI.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation

//Endpoint hold by OPass Official.
class OPassAPIViewModel: ObservableObject {
    
    @Published var eventList = [EventAPIViewModel]()
    @Published var currentEvent: EventAPIViewModel? = nil {
        willSet {
            if newValue?.eventSettings == nil {
                Task {
                    await newValue?.loadEventSettings_Logo()
                }
            }
        }
    }
    
    func loadEventList() async {
        if let eventList = try? await OPassRepo.loadEventList() {
            DispatchQueue.main.async {
                self.eventList = eventList
            }
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
