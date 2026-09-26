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

    static let legacyKey = "EventStore"

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
        try write(JSONEncoder().encode(event))
    }

    /// Moves the cache of earlier versions out of iCloud key-value storage, freeing its quota.
    func migrate(from keyStore: NSUbiquitousKeyValueStore) {
        guard let data = keyStore.data(forKey: Self.legacyKey) else { return }
        if !FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
            do {
                try write(data)
            } catch {
                logger.error("Failed to migrate cached event: \(error.localizedDescription)")
                return // Retried on the next launch
            }
        }
        keyStore.removeObject(forKey: Self.legacyKey)
        logger.info("Migrated cached event out of iCloud key-value storage")
    }

    private func write(_ data: Data) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var url = fileURL
        try url.setResourceValues(values)
    }
}
