//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2022 OPass.
//

import Foundation
import KeychainAccess
import OSLog
import OneSignal

///Endpoint hold by each Event Organization or hold by OPass Official but switch by Event Organization.
class EventAPIViewModel: ObservableObject {
    
    init(
        _ eventSettings: SettingsModel,
        eventLogo: Data? = nil,
        saveData: @escaping () async -> Void = {},
        tmpData: CodableEventAPIVM? = nil
    ) {
        self.event_id = eventSettings.event_id
        self.display_name = eventSettings.display_name
        self.logo_url = eventSettings.logo_url
        self.eventSettings = eventSettings
        self.eventLogo = eventLogo
        self.saveData = saveData
        self.eventAPITemporaryData = tmpData
    }
    
    var saveData: () async -> Void
    @Published var event_id: String
    @Published var display_name: DisplayTextModel
    @Published var logo_url: String
    @Published var eventSettings: SettingsModel
    @Published var eventLogo: Data? = nil
    @Published var eventSchedule: ScheduleModel? = nil
    @Published var eventAnnouncements: [AnnouncementModel]? = nil
    @Published var eventScenarioStatus: ScenarioStatusModel? = nil
    private var eventAPITemporaryData: CodableEventAPIVM? = nil
    
    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventAPI")
    private let keychain = Keychain(service: "app.opass.ccip-token")//Service key value match App Bundle ID + "-token"
        .synchronizable(true)
    
    var accessToken: String? {
        get {
            return try? keychain.get(self.event_id + "_token") //Key sample: SITCON_2020_token
        }
        set {
            if let accessToken = newValue {
                do {
                    try keychain.remove(self.event_id + "_token")
                    try keychain.set(accessToken, key: self.event_id + "_token")
                } catch {
                    logger.error("Save accessToken faild: \(error.localizedDescription)")
                }
            } else {
                logger.info("Set \"accessToken\" with nil, removing token")
                do {
                    try keychain.remove(self.event_id + "_token")
                } catch {
                    logger.error("Token remove error: \(error.localizedDescription)")
                }
            }
            objectWillChange.send()
        }
    }
    
    enum EventAPIError: Error {
        case noTokenFound
        case noCorrectFeatureFound
    }
}


extension EventAPIViewModel {
    ///Return bool to indicate success or not
    func useScenario(scenario: String) async -> Bool{
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        guard let token = accessToken else {
            logger.error("No accessToken included")
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
    
    ///Return bool to indicate token is valid or not. Will save token if is vaild.
    func redeemToken(token: String) async -> Bool {
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
                                    .alphanumerics
                                    .union(CharacterSet(charactersIn: "-_"))
                                    .inverted
        guard !token.isEmpty, !token.containsAny(nonAllowedCharacters) else {
            logger.info("Invalid accessToken of \(token)")
            return false
        }
        
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        
        if let eventScenarioStatus = try? await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token) {
            OneSignal.sendTag("\(eventScenarioStatus.event_id)\(eventScenarioStatus.role)", value: "\(eventScenarioStatus.token)")
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioStatus
                self.accessToken = token
                Task{ await self.saveData() }
            }
            return true
        }
        return false
    }
    
    func loadScenarioStatus() async throws {
        @Feature(.fastpass, in: eventSettings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        guard let token = accessToken else {
            logger.error("No accessToken included")
            throw EventAPIError.noTokenFound
        }
        
        do {
            let eventScenarioStatus = try await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token)
            DispatchQueue.main.async {
                self.eventScenarioStatus = eventScenarioStatus
                Task{ await self.saveData() }
            }
        } catch {
            guard let data = self.eventAPITemporaryData, let scenarioStatus = data.eventScenarioStatus else {
                throw error
            }
            self.eventAPITemporaryData?.eventScenarioStatus = nil
            DispatchQueue.main.async {
                self.eventScenarioStatus = scenarioStatus
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
        
        guard let scheduleFeature = scheduleFeature else {
            logger.critical("Can't find correct schedule feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        do {
            let schedule = try await APIRepo.load(scheduleFrom: scheduleFeature)
            DispatchQueue.main.async {
                self.eventSchedule = schedule
                Task { await self.saveData() }
            }
        } catch {
            guard let schedule = self.eventAPITemporaryData?.eventSchedule else {
                throw error
            }
            self.eventAPITemporaryData?.eventSchedule = nil
            DispatchQueue.main.async {
                self.eventSchedule = schedule
            }
        }
    }
    
    func loadAnnouncements() async throws {
        @Feature(.announcement, in: eventSettings) var announcementFeature
        
        guard let announcementFeature = announcementFeature else {
            logger.critical("Can't find correct announcement feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        do {
            let announcements = try await APIRepo.load(announcementFrom: announcementFeature, token: accessToken ?? "")
            DispatchQueue.main.async {
                self.eventAnnouncements = announcements
                Task{ await self.saveData() }
            }
        } catch {
            guard let announcements = self.eventAPITemporaryData?.eventAnnouncements else {
                throw error
            }
            self.eventAPITemporaryData?.eventAnnouncements = nil
            DispatchQueue.main.async {
                self.eventAnnouncements = announcements
            }
        }
    }
    
    func signOut() {
        OneSignal.sendTag("\(self.eventScenarioStatus?.event_id ?? "")\(self.eventScenarioStatus?.role ?? "")", value: "")
        self.eventScenarioStatus = nil
        self.accessToken = nil
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

// MARK: - Codable EventAPIViewModel
class CodableEventAPIVM: Codable {
    init(event_id: String,
         display_name: DisplayTextModel,
         logo_url: String,
         eventSettings: SettingsModel,
         eventLogo: Data?,
         eventSchedule: ScheduleModel?,
         eventAnnouncements: [AnnouncementModel]?,
         eventScenarioStatus: ScenarioStatusModel?) {
        self.event_id = event_id
        self.display_name = display_name
        self.logo_url = logo_url
        self.eventSettings = eventSettings
        self.eventLogo = eventLogo
        self.eventSchedule = eventSchedule
        self.eventAnnouncements = eventAnnouncements
        self.eventScenarioStatus = eventScenarioStatus
    }
    
    var event_id: String
    var display_name: DisplayTextModel
    var logo_url: String
    var eventSettings: SettingsModel
    var eventLogo: Data?
    var eventSchedule: ScheduleModel?
    var eventAnnouncements: [AnnouncementModel]?
    var eventScenarioStatus: ScenarioStatusModel?
}
