//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//

import Foundation

class EventViewModel: ObservableObject, Codable {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(event_id, forKey: .event_id)
        try container.encode(display_name, forKey: .display_name)
        try container.encode(logo_url, forKey: .logo_url)
    }
    
    
    @Published var event_id: String = ""
    @Published var display_name = DisplayTextModel()
    @Published var logo_url: String = ""
    @Published var eventSettings: EventSettingsModel? = nil
    @Published var eventLogo: Data? = nil
    @Published var eventSession: EventSessionModel? = nil
    
    func loadEventSettings_Logo() async {
        //Settings
        guard let SettingsUrl = URL(string: "https://portal.opass.app/events/\(event_id)") else {
            print("Invalid EventDetail URL")
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        
        do {
            let eventSettings: EventSettingsModel = try await URLSession.shared.jsonData(from: SettingsUrl)
            DispatchQueue.main.async {
                self.eventSettings = eventSettings
                group.leave()
            }
        } catch {
            print("EventSettingsDataError")
            return
        }
        
        group.wait()
        
        //Logo
        if let logoURL = self.eventSettings?.logo_url {
            guard let logoUrl = URL(string: logoURL) else {
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
    }
    
    func loadEventSession() async {
        let schefuleFeature = eventSettings?.features[ofType: .schedule]
        guard let session_url = schefuleFeature?.url else {
            print("Couldn't find session url in features")
            return
        }
        
        guard let url = URL(string: session_url) else {
            print("Invalid EventSession URL")
            DispatchQueue.main.async {
                self.eventSession = EventSessionModel()
            }
            return
        }
        do {
            let eventSession: EventSessionModel = try await URLSession.shared.jsonData(from: url)
            
            DispatchQueue.main.async {
                self.eventSession = eventSession
            }
        } catch {
            print("Invalid EventSession Data From API")
        }
    }
}

extension Array where Element == FeatureDetailModel {
    fileprivate subscript(ofType type: FeatureType) -> Element? {
        return self.first { $0.feature == type }
    }
}
