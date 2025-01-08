//
//  APIManager.swift
//  OPass
//
//  Created by secminhr on 2022/3/4.
//  2025 OPass.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "OPassData", category: "APIManager")

final class APIManager {
    public enum CCIPEndpoint {
        case events
        case config(String)
        case announcement(String, String?)
        case status(String, String)
        case use(String, String, String)
        case any(String)
        
        var string: String {
            switch self {
            case .events:
                return "https://portal.opass.app/events/"
            case .config(let id):
                return "https://portal.opass.app/events/\(id)"
            case .announcement(let baseUrl, let token):
                return "\(baseUrl)/announcement?token=\(token ?? "")"
            case .status(let baseUrl, let token):
                return "\(baseUrl)/status?token=\(token)"
            case .use(let baseUrl, let scenario, let token):
                return "\(baseUrl)/use/\(scenario)?token=\(token)"
            case .any(let url):
                return url
            }
        }
        
        var url: URL? { return URL(string: self.string) }
    }
    
    public enum LoadError: Error, LocalizedError {
        case invalidURL(CCIPEndpoint)
        case fetchFaild(Error)
        case decodeFaild(Error)
        case missingURL(Feature)
        case incorrectFeature(FeatureType)
        case forbidden
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL(let url):
                return "Invaild URL with \(url.string))"
            case .fetchFaild(let error):
                return "Fetch Faild with \(error.localizedDescription)"
            case .decodeFaild(let error):
                return "Decode Faild with \(error.localizedDescription)"
            case .missingURL(let feature):
                return "Missing URL in: \(feature.feature.rawValue)"
            case .incorrectFeature(let feature):
                return "Uncorrect Feature for: \(feature)"
            case .forbidden:
                return "Http 403 Forbidden"
            }
        }
    }
}

extension APIManager {
    // MARK: - OPass
    public static func fetchEvents(reload: Bool = false) async throws -> [Event] {
        return try await fetch(from: .events, reload: reload)
    }
    
    public static func fetchConfig(for event: String, reload: Bool = false) async throws -> EventConfig {
        return try await fetch(from: .config(event), reload: reload)
    }
    
    // MARK: - Event
    public static func fetchAttendee(
        from feature: Feature,
        token: String,
        scenario: String? = nil,
        reload: Bool = false
    ) async throws -> Attendee {
        guard feature.feature == .fastpass else {
            logger.critical("Can't find correct fastpass feature")
            throw LoadError.incorrectFeature(.fastpass)
        }
        guard let url = feature.url else {
            logger.error("Missing URL in feature: \(feature.feature.rawValue)")
            throw LoadError.missingURL(feature)
        }
        return try await fetch(from: scenario == nil ? .status(url, token) : .use(url, scenario!, token), reload: reload)
    }
    
    public static func fetchSchedule(
        from feature: Feature,
        reload: Bool = false
    ) async throws -> Schedule {
        guard feature.feature == .schedule else {
            logger.critical("Can't find correct schedule feature")
            throw LoadError.incorrectFeature(.schedule)
        }
        guard let url = feature.url else {
            logger.error("Missing URL in feature: \(feature.feature.rawValue)")
            throw LoadError.missingURL(feature)
        }
        return try await fetch(from: .any(url), reload: reload)
    }

    public static func fetchAnnouncements(
        from feature: Feature,
        token: String? = nil,
        reload: Bool = false
    ) async throws -> [Announcement] {
        guard feature.feature == .announcement else {
            logger.critical("Can't find correct announcement feature")
            throw LoadError.incorrectFeature(.announcement)
        }
        guard let url = feature.url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            logger.error("Missing URL in feature: \(feature.feature.rawValue)")
            throw LoadError.missingURL(feature)
        }
        return try await fetch(from: .announcement(url, token), reload: reload)
    }
    
    // MARK: - Data
    public static func fetchData(from endpoint: String) async throws -> Data {
        guard
            let endpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: endpoint)
        else {
            logger.error("Invalid URL: \(endpoint)")
            throw LoadError.invalidURL(.any(endpoint))
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    // MARK: - Private
    private static func fetch<T: Decodable>(from endpoint: CCIPEndpoint, reload: Bool = false) async throws -> T {
        guard let url = endpoint.url else {
            logger.error("Invalid URL: \(endpoint.string)")
            throw LoadError.invalidURL(endpoint)
        }
        do {
            let urlRequest = URLRequest(
                url: url,
                cachePolicy: reload ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy)
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 403:
                    logger.warning("Http 403 Forbidden with url: \(endpoint.string)")
                    throw LoadError.forbidden
                default:
                    break
                }
            }
            let decoder = JSONDecoder()
            decoder.userInfo[.needTransform] = true
            return try decoder.decode(T.self, from: data)
        } catch LoadError.forbidden {
            throw LoadError.forbidden
        } catch where error is DecodingError {
            logger.error("Decode Faild with: \(error.localizedDescription), url: \(endpoint.string)")
            throw LoadError.decodeFaild(error)
        } catch {
            logger.error("Fetch Faild with: \(error.localizedDescription), url: \(endpoint.string)")
            throw LoadError.fetchFaild(error)
        }
    }
}
