//
//  EventCacheTests.swift
//  OPassTests
//
//  Created by Brian Chang on 2026/9/26.
//  2026 OPass.
//

import Foundation
import Testing
@testable import OPass

struct EventCacheTests {
    final class FakeKeyValueStore: NSUbiquitousKeyValueStore {
        var values: [String: Any] = [:]

        override func data(forKey aKey: String) -> Data? { values[aKey] as? Data }
        override func removeObject(forKey aKey: String) { values[aKey] = nil }
    }

    let cache = EventCache(fileURL: FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString)/EventStore.json"))

    /// Larger than the 1 MB quota of iCloud key-value storage.
    func makeLargeEvent() -> EventStore {
        EventStore(.mock(), logoData: Data(repeating: 0xAB, count: 2_000_000))
    }

    @Test func savesEventLargerThanKeyValueStoreQuota() throws {
        try cache.save(makeLargeEvent())

        let event = try #require(cache.load())
        #expect(event.config == .mock())
        #expect(event.logoData == Data(repeating: 0xAB, count: 2_000_000))
        #expect(try cache.fileURL.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
    }

    @Test func loadsNothingWithoutCache() {
        #expect(cache.load() == nil)
    }

    @Test func migratesLegacyCache() throws {
        let keyStore = FakeKeyValueStore()
        keyStore.values[EventCache.legacyKey] = try JSONEncoder().encode(makeLargeEvent())

        cache.migrate(from: keyStore)

        #expect(keyStore.values.isEmpty)
        #expect(cache.load()?.logoData?.count == 2_000_000)
    }

    @Test func migrationKeepsExistingCache() throws {
        try cache.save(EventStore(.mock()))
        let keyStore = FakeKeyValueStore()
        keyStore.values[EventCache.legacyKey] = try JSONEncoder().encode(makeLargeEvent())

        cache.migrate(from: keyStore)

        #expect(keyStore.values.isEmpty)
        let event = try #require(cache.load())
        #expect(event.logoData == nil)
    }

    @Test func migrationWithoutLegacyCacheWritesNothing() {
        cache.migrate(from: FakeKeyValueStore())

        #expect(!FileManager.default.fileExists(atPath: cache.fileURL.path(percentEncoded: false)))
    }
}
