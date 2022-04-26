//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2022 OPass.
//

import Foundation
import KeychainAccess

//Endpoint hold by each Event Organization or hold by OPass Official but switch by Event Organization.
class EventAPIViewModel: ObservableObject {
    
    init(eventSettings: SettingsModel) {
        self.event_id = eventSettings.event_id
        self.display_name = eventSettings.display_name
        self.logo_url = eventSettings.logo_url
        self.eventSettings = eventSettings
    }
    
    @Published var event_id: String
    @Published var display_name: DisplayTextModel
    @Published var logo_url: String
    @Published var eventSettings: SettingsModel
    @Published var eventLogo: Data? = nil
    @Published var eventSchedule: ScheduleModel? = nil
    @Published var eventAnnouncements: [AnnouncementModel] = []
    @Published var eventScenarioStatus: ScenarioStatusModel? = nil
    @Published var isLogin: Bool = false
    
    private let keychain = Keychain(service: "app.opass.ccip-token") //Service key value match App Bundle ID + "-token"
        .synchronizable(true)
    var accessToken: String? { //DO NOT use this for view update beacuse it's not published. Use isLogin.
        get {
            return try? keychain.get(self.event_id + "_token") //Key sample: SITCON_2020_token
        }
        set {
            if let accessToken = newValue {
                do {
                    try keychain.remove(self.event_id + "_token")
                    try keychain.set(accessToken, key: self.event_id + "_token")
                } catch {
                    print("Save accessToken faild")
                }
            } else {
                print("AccessToken with nil, remove token")
                do {
                    try keychain.remove(self.event_id + "_token")
                } catch {
                    print("Token remove error")
                }
            }
        }
    }
    
    func useScenario(scenario: String) async -> Bool{ //Scenario switch by scenario ID. Return true/false for view update
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        guard let token = accessToken else {
            print("No accessToken included")
            return false
        }
        
        if let eventScenarioUseStatus = try? await APIRepo.load(scenarioUseFrom: fastpassFeature, scenario: scenario, token: token) {
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioUseStatus
            }
            return true
        }
        return false
    }
    
    func redeemToken(token: String) async -> Bool { //Save token after token check
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
                                    .alphanumerics
                                    .union(CharacterSet(charactersIn: "-_"))
                                    .inverted
        if (token.isEmpty || token.containsAny(nonAllowedCharacters)) {
            print("Invalid accessToken")
            return false
        }
        
        self.isLogin = false
        
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        
        if let eventScenarioStatus = try? await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token) {
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioStatus
                self.accessToken = token
                self.isLogin = true
            }
            return true
        } else  {
            return false
        }
    }
    
    func loadScenarioStatus() async {
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        
        guard let token = accessToken else {
            print("No accessToken included")
            return
        }
        
        if let eventScenarioStatus = try? await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token) {
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioStatus
                self.isLogin = true
            }
        }
    }
    
    func initialization() async {
        //Load Event Settings
//        guard let eventSettings = try? await APIRepo.loadSettings(ofEvent: event_id) else {
//            return
//        }
        
//        DispatchQueue.main.async {
//            self.eventSettings = eventSettings
//        }
        
        //Load Event Logo
        if let logo = try? await APIRepo.loadLogo(from: eventSettings.logo_url) {
            DispatchQueue.main.async {
                self.eventLogo = logo
            }
        }
        //Load WebView Icon
        let webViewFeatureIndex = eventSettings.features.enumerated().filter({ $0.element.feature == .webview }).map { $0.offset }
        
        for index in webViewFeatureIndex {
            if let iconUrl = eventSettings.features[index].icon, let iconData = try? await APIRepo.loadLogo(from: iconUrl) {
                DispatchQueue.main.async {
//                    self.eventSettings!.features[index].iconData = iconData
                    self.eventSettings.features[index].iconData = iconData
                }
            }
        }
    }
    
    func loadSchedule() async {
        @Feature(.schedule, in: eventSettings) var scheduleFeature
        
        if let schedule = try? await APIRepo.load(scheduleFrom: scheduleFeature) {
            DispatchQueue.main.async {
                self.eventSchedule = schedule
            }
        }
    }
    
    func loadAnnouncements() async {
        @Feature(.announcement, in: eventSettings) var announcementFeature
        
        guard let token = accessToken else {
            print("No accessToken included")
            return
        }
        
        if let announcements = try? await APIRepo.load(announcementFrom: announcementFeature, token: token) {
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

extension String {
    func tirm() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func containsAny(_ characterSet: CharacterSet) -> Bool {
        return rangeOfCharacter(from: characterSet) != nil
    }
}
