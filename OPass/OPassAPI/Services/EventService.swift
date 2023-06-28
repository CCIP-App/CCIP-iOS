//
//  EventService.swift
//  OPass
//
//  Created by 張智堯 on 2022/3/3.
//  2023 OPass.
//

import SwiftUI
import KeychainAccess
import OSLog

class EventService: ObservableObject {
    
    init(
        _ settings: SettingsModel,
        logo_data: Data? = nil,
        saveData: @escaping () async -> Void = {},
        tmpData: CodableEventService? = nil
    ) {
        self.event_id = settings.event_id
        self.display_name = settings.display_name
        self.logo_url = settings.logo_url
        self.logo_data = logo_data
        self.settings = settings
        self.save = saveData
        self._user_id = AppStorage(wrappedValue: "nil", "user_id", store: .init(suiteName: settings.event_id))
        self._user_role = AppStorage(wrappedValue: "nil", "user_role", store: .init(suiteName: settings.event_id))
        self._liked_sessions = AppStorage(wrappedValue: [], "liked_sessions", store: .init(suiteName: settings.event_id))
        self.eventAPITmpData = tmpData
    }
    
    @Published var event_id: String
    @Published var display_name: DisplayTextModel
    @Published var logo_url: String
    @Published var logo_data: Data? = nil
    @Published var settings: SettingsModel
    @Published var schedule: ScheduleModel? = nil
    @Published var announcements: [AnnouncementModel]? = nil
    @Published var scenario_status: ScenarioStatusModel? = nil
    @AppStorage var user_id: String
    @AppStorage var user_role: String
    @AppStorage var liked_sessions: [String]
    var save: () async -> Void
    var logo: Image? {
        guard let data = logo_data else { return nil }
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
    var user_token: String? {
        get { try? keychain.get("\(self.event_id)_token") }
        set {
            if let user_token = newValue {
                do { try keychain.set(user_token, key: "\(self.event_id)_token") }
                catch { logger.error("Save user_token faild: \(error.localizedDescription)") }
            } else {
                do { try keychain.remove("\(self.event_id)_token") }
                catch { logger.error("Token remove error: \(error.localizedDescription)") }
            }
            objectWillChange.send()
        }
    }
    
    private var eventAPITmpData: CodableEventService? = nil
    private let logger = Logger(subsystem: "app.opass.ccip", category: "EventAPI")
    private let keychain = Keychain(service: "app.opass.ccip-token").synchronizable(true)
    
    enum EventAPIError: Error {
        case noTokenFound
        case noCorrectFeatureFound
    }
}

extension EventService {
    ///Return bool to indicate success or not
    func useScenario(scenario: String) async throws -> Bool{
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        guard let token = user_token else {
            logger.error("No user_token included")
            return false
        }
        
        do {
            let eventScenarioUseStatus = try await APIRepo.load(scenarioUseFrom: fastpassFeature, scenario: scenario, token: token)
            DispatchQueue.main.async {
                self.scenario_status = eventScenarioUseStatus
                Task{ await self.save() }
            }
            return true
        } catch APIRepo.LoadError.forbidden {
            throw APIRepo.LoadError.forbidden
        } catch { return false }
    }
    
    ///Return bool to indicate token is valid or not. Will save token if is vaild.
    func redeemToken(token: String) async throws -> Bool {
        let token = token.tirm()
        let nonAllowedCharacters = CharacterSet
            .alphanumerics
            .union(CharacterSet(charactersIn: "-_"))
            .inverted
        guard token.isNotEmpty, !token.containsAny(nonAllowedCharacters) else {
            logger.info("Invalid user_token of \(token)")
            return false
        }
        
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            return false
        }
        
        do {
            let scenario_status = try await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token)
            Constants.sendTag("\(scenario_status.event_id)\(scenario_status.role)", value: "\(scenario_status.token)")
            DispatchQueue.main.async {
                self.scenario_status = scenario_status
                self.user_token = token
                self.user_id = scenario_status.user_id ?? "nil"
                self.user_role = scenario_status.role
                Task{ await self.save() }
            }
            return true
        } catch APIRepo.LoadError.forbidden {
            throw APIRepo.LoadError.forbidden
        } catch { return false }
    }
    
    func loadScenarioStatus() async throws {
        @Feature(.fastpass, in: settings) var fastpassFeature
        
        guard let fastpassFeature = fastpassFeature else {
            logger.critical("Can't find correct fastpass feature")
            throw EventAPIError.noCorrectFeatureFound
        }
        guard let token = user_token else {
            logger.error("No user_token included")
            throw EventAPIError.noTokenFound
        }
        
        do {
            let scenario_status = try await APIRepo.load(scenarioStatusFrom: fastpassFeature, token: token)
            DispatchQueue.main.async {
                self.scenario_status = scenario_status
                self.user_id = scenario_status.user_id ?? "nil"
                self.user_role = scenario_status.role
                Task{ await self.save() }
            }
        } catch APIRepo.LoadError.forbidden {
            throw APIRepo.LoadError.forbidden
        } catch {
            guard let data = self.eventAPITmpData, let scenario_status = data.scenario_status else {
                throw error
            }
            self.eventAPITmpData?.scenario_status = nil
            DispatchQueue.main.async {
                self.user_id = scenario_status.user_id ?? "nil"
                self.user_role = scenario_status.role
                self.scenario_status = scenario_status
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
                    self.logo_data = data
                } else {
                    self.settings.features[index].iconData = data
                }
            }
        }
        Task{ await self.save() }
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
                Task { await self.save() }
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
            let announcements = try await APIRepo.load(announcementFrom: announcementFeature, token: user_token ?? "")
            DispatchQueue.main.async {
                self.announcements = announcements
                Task{ await self.save() }
            }
        } catch  APIRepo.LoadError.forbidden {
            throw APIRepo.LoadError.forbidden
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
        if let scenario_status = scenario_status {
            Constants.sendTag("\(scenario_status.event_id)\(scenario_status.role)", value: "")
            self.scenario_status = nil
            self.user_id = "nil"
            self.user_role = "nil"
        }
        self.user_token = nil
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

// MARK: - Codable EventService
class CodableEventService: Codable {
    init(event_id: String,
         display_name: DisplayTextModel,
         logo_url: String,
         settings: SettingsModel,
         logo_data: Data?,
         schedule: ScheduleModel?,
         announcements: [AnnouncementModel]?,
         scenario_status: ScenarioStatusModel?) {
        self.event_id = event_id
        self.display_name = display_name
        self.logo_url = logo_url
        self.settings = settings
        self.logo_data = logo_data
        self.schedule = schedule
        self.announcements = announcements
        self.scenario_status = scenario_status
    }
    
    var event_id: String
    var display_name: DisplayTextModel
    var logo_url: String
    var settings: SettingsModel
    var logo_data: Data?
    var schedule: ScheduleModel?
    var announcements: [AnnouncementModel]?
    var scenario_status: ScenarioStatusModel?
}
