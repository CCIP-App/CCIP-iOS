//
//  APIManager.swift
//  OPass
//
//  Created by Brian Chang on 2022/11/19.
//  2023 OPass.
//

import Foundation
import OSLog

class APIManager {
    static let shared = APIManager()
    
    enum CCIPEndpoint {
        case events
        case config(String)
        case announcement(String, String?)
        case status(String, String)
        case use(String, String, String)
        
        var url: String {
            switch self {
            case .events: return "https://portal.opass.app/events/"
            case .config(let id): return "https://portal.opass.app/events/\(id)"
            case .announcement(let baseUrl, let token): return "\(baseUrl)/announcement?token=\(token ?? "")"
            case .status(let baseUrl, let token): return "\(baseUrl)/status?token=\(token)"
            case .use(let baseUrl, let scenario, let token): return "\(baseUrl)/use/\(scenario)?token=\(token)"
            }
        }
    }
    enum APIError: Error, LocalizedError {
        case invaildUrl(String)
        case fetchFaild(Error)
        case decodeFaild(Error)
        case uncorrectFeature(String)
        case missedUrl(FeatureType)
        case forbidden
        
        var errorDescription: String? {
            switch self {
            case .invaildUrl(let url): return "Invaild URL with \(url)"
            case .fetchFaild(let error): return "Fetch Faild with \(error.localizedDescription)"
            case .decodeFaild(let error): return "Decode Faild with \(error.localizedDescription)"
            case .uncorrectFeature(let feature): return "Uncorrect Feature with \(feature)"
            case .missedUrl(let feature): return "Missing URL with \(feature.rawValue)"
            case .forbidden: return "Http 403 Forbidden"
            }
        }
    }
}

extension APIManager {
    func fetchEvents(completion: @MainActor @escaping (Result<[EventTitleModel], APIError>) -> Void) async {
        return await fetch(from: .events, type: [EventTitleModel].self, completion: completion)
    }
    
    func fetchConfig(for id: String, completion: @MainActor @escaping (Result<SettingsModel, APIError>) -> Void) async {
        return await fetch(from: .config(id), type: SettingsModel.self, completion: completion)
    }
}

extension APIManager {
    func fetchAnnouncement(@Feature(.announcement) from feature: FeatureModel?, with token: String?, completion: @MainActor @escaping (Result<[AnnouncementModel], APIError>) -> Void) async {
        guard let feature = feature else {
            return await completion(.failure(.uncorrectFeature("announcement")))
        }
        guard let baseUrl = feature.url else {
            return await completion(.failure(.missedUrl(feature.feature)))
        }
        return await fetch(from: .announcement(baseUrl, token), type: [AnnouncementModel].self, completion: completion)
    }
    
    func fetchStatus(@Feature(.fastpass) from feature: FeatureModel?, with token: String, completion: @MainActor @escaping (Result<ScenarioStatusModel, APIError>) -> Void) async {
        guard let feature = feature else {
            return await completion(.failure(.uncorrectFeature("fastpass")))
        }
        guard let baseUrl = feature.url else {
            return await completion(.failure(.missedUrl(feature.feature)))
        }
        return await fetch(from: .status(baseUrl, token), type: ScenarioStatusModel.self, completion: completion)
    }
    
    func fetchStatus(@Feature(.fastpass) from feature: FeatureModel?, using scenario: String, with token: String, completion: @MainActor @escaping (Result<ScenarioStatusModel, APIError>) -> Void) async {
        guard let feature = feature else {
            return await completion(.failure(.uncorrectFeature("fastpass")))
        }
        guard let baseUrl = feature.url else {
            return await completion(.failure(.missedUrl(feature.feature)))
        }
        return await fetch(from: .use(baseUrl, scenario, token), type: ScenarioStatusModel.self, completion: completion)
    }
}

extension APIManager {
    func fetchData(from endpoint: String, completion: @MainActor @escaping (Result<Data, APIError>) -> Void) async {
        return await fetch(from: endpoint, type: Data.self, completion: completion)
    }
    
    func fetch<T: Decodable>(from endpoint: CCIPEndpoint, type: T.Type, completion: @MainActor @escaping (Result<T, APIError>) -> Void) async {
        return await fetch(from: endpoint.url, type: type, completion: completion)
    }
    
    func fetch<T: Decodable>(from endpoint: String, type: T.Type, completion: @MainActor @escaping (Result<T, APIError>) -> Void) async {
        guard let url = URLComponents(string: endpoint)?.url else {
            return await completion(.failure(.invaildUrl(endpoint)))
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 403: return await completion(.failure(.forbidden))
                default: break
                }
            }
            let decoder = JSONDecoder()
            decoder.userInfo[.needTransform] = true
            let result = try decoder.decode(type, from: data)
            return await completion(.success(result))
        } catch where error is DecodingError {
            return await completion(.failure(.decodeFaild(error)))
        } catch {
            return await completion(.failure(.fetchFaild(error)))
        }
    }
}
