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
    @Published var currentEventAPI: EventAPIViewModel? = nil {
        willSet {
            if newValue?.eventSettings == nil {
                Task {
                    await newValue?.loadSettings_Logo()
                }
            }
        }
    }
    
    func loadEventList() async {
        if let eventList = try? await APIRepo.loadEventList() {
            DispatchQueue.main.async {
                self.eventList = eventList
            }
        }
    }
    
    func loginEvent(_ eventId: String, withToken token: String) async {
        do {
            let eventModel = try await APIRepo.loadEvent(id: eventId)
            //Awe call and await loadSettings_Logo manually to make sure that redeemToken can have valid eventSettings
            await eventModel.loadSettings_Logo()
            DispatchQueue.main.async {
                self.currentEventAPI = eventModel
            }
            await eventModel.redeemToken(token: token)
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
