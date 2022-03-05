//
//  OPassRepo.swift
//  OPass
//
//  Created by secminhr on 2022/3/4.
//

import Foundation
import SwiftDate

final class OPassRepo {
    enum LoadError: Error {
        case invalidURL(url: URLs)
        case dataFetchingFailed(cause: Error)
        case incorrectFeatureType(require: FeatureType, found: FeatureType)
        case missingURL(feature: FeatureDetailModel)
        case invalidDateString(String)
    }
    enum URLs {
        case eventList
        case eventSettings(String)
        case announcements(String, String)
        case raw(String)
        
        func getString() -> String {
            switch self {
                case .eventList:
                    return "https://portal.opass.app/events/"
                case .eventSettings(let id):
                    return "https://portal.opass.app/events/\(id)"
                case .announcements(let baseURL, let token):
                    return "\(baseURL)/announcement?token=\(token)"
                case .raw(let url):
                    return url
            }
        }
    }
    
    static func loadEventList() async throws -> [EventAPIViewModel] {
        guard let url = URL(.eventList) else {
            print("Invalid EventList URL")
            throw LoadError.invalidURL(url: .eventList)
        }
        
        do {
            return try await URLSession.shared.jsonData(from: url)
        } catch {
            print("Invalid EventList Data From API")
            throw LoadError.dataFetchingFailed(cause: error)
        }
    }
    
    static func loadSettings(ofEvent eventId: String) async throws -> EventSettingsModel {
        guard let SettingsUrl = URL(.eventSettings(eventId)) else {
            print("Invalid EventDetail URL")
            throw LoadError.invalidURL(url: .eventSettings(eventId))
        }
        
        do {
            return try await URLSession.shared.jsonData(from: SettingsUrl)
        } catch {
            print("EventSettingsDataError")
            throw LoadError.dataFetchingFailed(cause: error)
        }
    }
    
    static func loadLogo(from url: String) async throws -> Data {
        guard let logoUrl = URL(string: url) else {
            print("Invalid Sessions PNG URL")
            throw LoadError.invalidURL(url: .raw(url))
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: logoUrl)
            return data
        } catch {
            print("EventLogoError")
            throw LoadError.dataFetchingFailed(cause: error)
        }
    }
    
    static func loadSession(fromSchedule schedule: FeatureDetailModel) async throws -> EventSessionModel {
        guard schedule.feature == .schedule else {
            throw LoadError.incorrectFeatureType(require: .schedule, found: schedule.feature)
        }
        
        guard let session_url = schedule.url else {
            print("Couldn't find session url in schedule feature")
            throw LoadError.missingURL(feature: schedule)
        }
        
        guard let url = URL(string: session_url) else {
            print("Invalid EventSession URL")
            throw LoadError.invalidURL(url: .raw(session_url))
        }
        
        do {
            return try await URLSession.shared.jsonData(from: url)
        } catch {
            print("Invalid EventSession Data From API")
            print(error)
            throw LoadError.dataFetchingFailed(cause: error)
        }
    }
    
    static func loadAnnouncement(from feature: FeatureDetailModel) async throws -> [AnnouncementModel] {
        guard feature.feature == .announcement else {
            throw LoadError.incorrectFeatureType(require: .announcement, found: feature.feature)
        }
        guard let baseURL = feature.url else {
            throw LoadError.missingURL(feature: feature)
        }
        //since token part is under development, a temporary token from ccip sample is used
        let token = "7679f08f7eaeef5e9a65a1738ae2840e"
        
        guard let url = URL(.announcements(baseURL, token)) else {
            throw LoadError.invalidURL(url: .announcements(baseURL, token))
        }
        
        do {
            return try await URLSession.shared.jsonData(from: url)
        } catch {
            throw LoadError.dataFetchingFailed(cause: error)
        }
    }
}

extension URL {
    fileprivate init?(_ urlType: OPassRepo.URLs) {
        self.init(string: urlType.getString())
    }
}

extension URLSession {
    func jsonData<T: Decodable>(from url: URL) async throws -> T {
        let (data, _) = try await self.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
