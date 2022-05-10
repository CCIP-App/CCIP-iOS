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
    
    init(eventSettings: SettingsModel,
         eventLogo: Data? = nil,
         eventSchedule: ScheduleModel? = nil,
         eventAnnouncements: [AnnouncementModel] = [],
         eventScenarioStatus: ScenarioStatusModel? = nil,
         isLogin: Bool = false,
         saveData: @escaping () async -> Void = {}
    ) {
        self.event_id = eventSettings.event_id
        self.display_name = eventSettings.display_name
        self.logo_url = eventSettings.logo_url
        self.eventSettings = eventSettings
        self.eventLogo = eventLogo
        self.eventSchedule = eventSchedule
        self.eventAnnouncements = eventAnnouncements
        self.eventScenarioStatus = eventScenarioStatus
        self.isLogin = isLogin
        self.saveData = saveData
    }
    
    var saveData: () async -> Void
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
                Task{ await self.saveData() }
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
                Task{ await self.saveData() }
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
                Task{ await self.saveData() }
            }
        }
    }
    
    func loadLogos() async {
        //Load Event Logo
        let icons: [Int: Data] = await withTaskGroup(of: (Int, Data?).self) { group in
            let logo_url = eventSettings.logo_url
            let webViewFeatureIndex = eventSettings.features.enumerated().filter({ $0.element.feature == .webview }).map { $0.offset }
            
            group.addTask { (-1, try? await APIRepo.loadLogo(from: logo_url)) }
            for index in webViewFeatureIndex {
                if let iconUrl = eventSettings.features[index].icon{
                    group.addTask { (index, try? await APIRepo.loadLogo(from: iconUrl)) }
                }
            }
            
            var indexToIcon: [Int: Data] = [:]
            for await (index, data) in group {
                if data != nil {
                    indexToIcon[index] = data
                }
            }
            return indexToIcon
        }
        
        for (index, data) in icons {
            DispatchQueue.main.async {
                if index == -1 {
                    self.eventLogo = data
                } else {
                    self.eventSettings.features[index].iconData = data
                }
            }
        }
        Task{ await self.saveData() }
    }
    
    func loadSchedule() async throws {
        @Feature(.schedule, in: eventSettings) var scheduleFeature
        
        let schedule = try await APIRepo.load(scheduleFrom: scheduleFeature)
        DispatchQueue.main.async {
            self.eventSchedule = schedule
            Task { await self.saveData() }
        }
    }
    
    func loadAnnouncements() async throws {
        @Feature(.announcement, in: eventSettings) var announcementFeature
        
        let announcements = try await APIRepo.load(announcementFrom: announcementFeature, token: accessToken ?? "")
        DispatchQueue.main.async {
            self.eventAnnouncements = announcements
            Task{ await self.saveData() }
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

class CodableEventAPIVM: Codable {
    
    init(event_id: String,
         display_name: DisplayTextModel,
         logo_url: String,
         eventSettings: SettingsModel,
         eventLogo: Data?,
         eventSchedule: ScheduleModel?,
         eventAnnouncements: [AnnouncementModel],
         eventScenarioStatus: ScenarioStatusModel?,
         isLogin: Bool) {
        self.event_id = event_id
        self.display_name = display_name
        self.logo_url = logo_url
        self.eventSettings = eventSettings
        self.eventLogo = eventLogo
        self.eventSchedule = eventSchedule
        self.eventAnnouncements = eventAnnouncements
        self.eventScenarioStatus = eventScenarioStatus
        self.isLogin = isLogin
    }
    
    var event_id: String
    var display_name: DisplayTextModel
    var logo_url: String
    var eventSettings: SettingsModel
    var eventLogo: Data?
    var eventSchedule: ScheduleModel?
    var eventAnnouncements: [AnnouncementModel]
    var eventScenarioStatus: ScenarioStatusModel?
    var isLogin: Bool
}
