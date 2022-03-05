//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//

import Foundation
import KeychainAccess

//Endpoint hold by each Event Organization or hold by OPass Official but switch by Event Organization.
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
    
    private let keychain = Keychain(service: "app.opass.ccip")
    
    @Published var event_id: String = ""
    @Published var display_name = DisplayTextModel()
    @Published var logo_url: String = ""
    @Published var eventSettings: EventSettingsModel? = nil
    @Published var eventLogo: Data? = nil
    @Published var eventSession: EventSessionModel? = nil
    @Published var eventAnnouncements: [AnnouncementModel] = []
    @Published var eventScenarioStatus: EventScenarioStatusModel? = nil
    @Published var isLogin: Bool = false
    
    var accessToken: String? {
        get {
            return try? keychain.get(self.event_id + "_token")
        }
        set {
            if let accessToken = newValue {
                do {
                    try keychain.remove(self.event_id + "_token")
                    try keychain.set(accessToken, key: self.event_id + "_token")
                } catch {
                    print("save accessToken faild")
                }
            } else {
                print("No accessToken")
            }
        }
    }
    
    func loadEventScenarioStatus() async {
        guard let url = eventSettings?.features[ofType: .fastpass]?.url else {
            print("FastPass feature or URL is not included")
            return
        }
        
        guard let token = accessToken else {
            print("No accessToken included")
            return
        }
        
        if let eventScenarioStatus = try? await OPassRepo.loadEventScenarioStatus(url: url, token: token) {
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioStatus
            }
        }
    }
    
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
    
    func loadAnnouncements() async {
        guard let announcementFeature = eventSettings?.features[ofType: .announcement] else {
            print("Announcement feature is not included")
            return
        }
        
        if let announcements = try? await OPassRepo.loadAnnouncement(from: announcementFeature, token: accessToken ?? "") {
            DispatchQueue.main.async {
                self.eventAnnouncements = announcements
            }
        } else {
            DispatchQueue.main.async {
                self.eventAnnouncements = []
            }
        }
    }
}

extension Array where Element == FeatureDetailModel {
    fileprivate subscript(ofType type: FeatureType) -> Element? {
        return self.first { $0.feature == type }
    }
}
