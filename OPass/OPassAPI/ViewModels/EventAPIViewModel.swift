//
//  EventViewModel.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2022 OPass.
//

import SwiftUI
import KeychainAccess
import OSLog

///Endpoint hold by each Event Organization or hold by OPass Official but switch by Event Organization.
class EventAPIViewModel: ObservableObject {
    
    init(
        _ settings: SettingsModel,
        logo: Data? = nil,
        saveData: @escaping () async -> Void = {},
        tmpData: CodableEventAPIVM? = nil
    ) {
        self.event_id = settings.event_id
        self.display_name = settings.display_name
        self.logo_url = settings.logo_url
        self.settings = settings
        self.logo = logo
        self.saveData = saveData
        self._user_role = AppStorage(wrappedValue: "nil", "user_role", store: .init(suiteName: settings.event_id))
        self._liked_sessions = AppStorage(wrappedValue: [], "liked_sessions", store: .init(suiteName: settings.event_id))
        self.eventAPITmpData = tmpData
    }
    
    var saveData: () async -> Void
    @Published var event_id: String
    @Published var display_name: DisplayTextModel
    @Published var logo_url: String
    @Published var settings: SettingsModel
    @Published var logo: Data? = nil
    @Published var schedule: ScheduleModel? = nil
    @Published var announcements: [AnnouncementModel]? = nil
    @Published var scenarioStatus: ScenarioStatusModel? = nil
    @AppStorage var user_role: String
    @AppStorage var liked_sessions: [String]
    private var eventAPITmpData: CodableEventAPIVM? = nil
    
    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventAPI")
    private let keychain = Keychain(service: "app.opass.ccip-token")
        .synchronizable(true)
    
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
    func useScenario(scenario: String) async throws -> Bool{
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        guard let token = accessToken else {
            logger.error("No accessToken included")
            return false
        }
        
        do {
            let eventScenarioUseStatus = try await APIRepo.load(scenarioUseFrom: fastpassFeature, scenario: scenario, token: token)
            DispatchQueue.main.async {
                self.scenarioStatus = eventScenarioUseStatus
                Task{ await self.saveData() }
            }
            return true
        } catch APIRepo.LoadError.http403Forbidden {
            throw APIRepo.LoadError.http403Forbidden
        } catch { return false }
    }
    
    ///Return bool to indicate token is valid or not. Will save token if is vaild.
    func redeemToken(token: String) async throws -> Bool {
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
                                    .alphanumerics
                                    .union(CharacterSet(charactersIn: "-_"))
                                    .inverted
        guard !token.isEmpty, !token.containsAny(nonAllowedCharacters) else {
            logger.info("Invalid accessToken of \(token)")
            return false
        }
        
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        
        do {
            let scenarioStatus = try await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token)
            Constants.sendTag("\(scenarioStatus.event_id)\(scenarioStatus.role)", value: "\(scenarioStatus.token)")
            DispatchQueue.main.async {
                self.scenarioStatus = scenarioStatus
                self.accessToken = token
                self.user_role = scenarioStatus.role
                Task{ await self.saveData() }
            }
            return true
        } catch APIRepo.LoadError.http403Forbidden {
            throw APIRepo.LoadError.http403Forbidden
        } catch { return false }
    }
    
    func loadScenarioStatus() async throws {
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        guard let token = accessToken else {
            logger.error("No accessToken included")
            throw EventAPIError.noTokenFound
        }
        
        do {
            let scenarioStatus = try await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token)
            DispatchQueue.main.async {
                self.scenarioStatus = scenarioStatus
                self.user_role = scenarioStatus.role
                Task{ await self.saveData() }
            }
        } catch APIRepo.LoadError.http403Forbidden {
            throw APIRepo.LoadError.http403Forbidden
        } catch {
            guard let data = self.eventAPITmpData, let scenarioStatus = data.scenarioStatus else {
                throw error
            }
            self.eventAPITmpData?.scenarioStatus = nil
            DispatchQueue.main.async {
                self.user_role = scenarioStatus.role
                self.scenarioStatus = scenarioStatus
            }
        }
    }
    
    func loadLogos() async {
        //Load Event Logo
        let icons: [Int: Data] = await withTaskGroup(of: (Int, Data?).self) { group in
            let logo_url = settings.logo_url
            let webViewFeatureIndex = settings.features.enumerated().filter({ $0.element.feature == .webview }).map { $0.offset }
            
            group.addTask { (-1, try? await APIRepo.loadLogo(from: logo_url)) }
            for index in webViewFeatureIndex {
                if let iconUrl = settings.features[index].icon{
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
                    self.logo = data
                } else {
                    self.settings.features[index].iconData = data
                }
            }
        }
        Task{ await self.saveData() }
    }
    
    func loadSchedule() async throws {
        @Feature(.schedule, in: settings) var scheduleFeature
        
        guard let scheduleFeature = scheduleFeature else {
            logger.critical("Can't find correct schedule feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        do {
            let schedule = try await APIRepo.load(scheduleFrom: scheduleFeature)
            DispatchQueue.main.async {
                self.schedule = schedule
                Task { await self.saveData() }
            }
        } catch {
            guard let schedule = self.eventAPITmpData?.schedule else {
                throw error
            }
            self.eventAPITmpData?.schedule = nil
            DispatchQueue.main.async {
                self.schedule = schedule
            }
        }
    }
    
    func loadAnnouncements() async throws {
        @Feature(.announcement, in: settings) var announcementFeature
        
        guard let announcementFeature = announcementFeature else {
            logger.critical("Can't find correct announcement feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        do {
            let announcements = try await APIRepo.load(announcementFrom: announcementFeature, token: accessToken ?? "")
            DispatchQueue.main.async {
                self.announcements = announcements
                Task{ await self.saveData() }
            }
        } catch  APIRepo.LoadError.http403Forbidden {
            throw APIRepo.LoadError.http403Forbidden
        } catch {
            guard let announcements = self.eventAPITmpData?.announcements else {
                throw error
            }
            self.eventAPITmpData?.announcements = nil
            DispatchQueue.main.async {
                self.announcements = announcements
            }
        }
    }
    
    func signOut() {
        if let scenarioStatus = scenarioStatus {
            Constants.sendTag("\(scenarioStatus.event_id)\(scenarioStatus.role)", value: "")
            self.scenarioStatus = nil
            self.user_role = "nil"
        }
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
         settings: SettingsModel,
         logo: Data?,
         schedule: ScheduleModel?,
         announcements: [AnnouncementModel]?,
         scenarioStatus: ScenarioStatusModel?) {
        self.event_id = event_id
        self.display_name = display_name
        self.logo_url = logo_url
        self.settings = settings
        self.logo = logo
        self.schedule = schedule
        self.announcements = announcements
        self.scenarioStatus = scenarioStatus
    }
    
    var event_id: String
    var display_name: DisplayTextModel
    var logo_url: String
    var settings: SettingsModel
    var logo: Data?
    var schedule: ScheduleModel?
    var announcements: [AnnouncementModel]?
    var scenarioStatus: ScenarioStatusModel?
}
