//
//  Structs.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/1.
//

import Foundation


class EventModel: ObservableObject, Codable {
    //conform to Codable
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
    @Published var display_name: DisplayTextModel = DisplayTextModel(en: "", zh: "")
    @Published var logo_url: String = ""
    @Published var eventSettings: EventSettingsModel? = nil
    @Published var eventLogo: Data? = nil
    
    func loadEventSettings_Logo() async {
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
}

struct DisplayTextModel: Hashable, Codable {
    var en: String
    var zh: String
}
