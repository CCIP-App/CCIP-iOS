//
//  EventCache.swift
//  OPass
//
//  Created by Brian Chang on 2026/9/26.
//  2026 OPass.
//

import Foundation
import OSLog

private let logger = Logger(subsystem: "OPassData", category: "EventCache")

struct EventCache {
    static let shared = EventCache(fileURL: .applicationSupportDirectory.appending(path: "EventStore.json"))

    let fileURL: URL

    func load() -> EventStore? {
        guard let data = try? Data(contentsOf: fileURL) else {
            logger.info("No cached event was found")
            return nil
        }
        do {
            return try JSONDecoder().decode(EventStore.self, from: data)
        } catch {
            logger.error("Unable to decode cached event: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ event: EventStore) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(event).write(to: fileURL, options: .atomic)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = fileURL
        try url.setResourceValues(values)
    }
}
