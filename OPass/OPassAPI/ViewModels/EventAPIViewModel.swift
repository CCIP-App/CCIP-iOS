//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//

import Foundation

//Endpoint hold by each Event Organization.
class EventAPIViewModel: ObservableObject, Decodable {
    //Conform to Codable
    enum CodingKeys: CodingKey {
        case event_id, display_name, logo_url
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        event_id = try container.decode(String.self, forKey: .event_id)
        display_name = try container.decode(DisplayTextModel.self, forKey: .display_name)
        logo_url = try container.decode(String.self, forKey: .logo_url)
    }
    
    @Published var event_id: String = ""
    @Published var display_name = DisplayTextModel()
    @Published var logo_url: String = ""
    @Published var eventSettings: EventSettingsModel? = nil
    @Published var eventLogo: Data? = nil
    @Published var eventSession: EventSessionModel? = nil
    
    func loadEventSettings_Logo() async {
        guard let eventSettings = try? await OPassRepo.loadSettings(ofEvent: event_id) else {
            print("load settings failed")
            return
        }
        DispatchQueue.main.async {
            self.eventSettings = eventSettings
        }

        if let logo = try? await OPassRepo.loadLogo(from: eventSettings.logo_url) {
            DispatchQueue.main.async {
                self.eventLogo = logo
            }
        }
    }
    
    func loadEventSession() async {
        guard let scheduleFeature = eventSettings?.features[ofType: .schedule] else {
            print("Schedule feature is not included")
            return
        }
        
        if let session = try? await OPassRepo.loadSession(fromSchedule: scheduleFeature) {
            DispatchQueue.main.async {
                self.eventSession = session
            }
        }
    }
}

extension Array where Element == FeatureDetailModel {
    fileprivate subscript(ofType type: FeatureType) -> Element? {
        return self.first { $0.feature == type }
    }
}
