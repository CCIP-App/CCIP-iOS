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

    func makeConfigWithIcon() throws -> EventConfig {
        var config = EventConfig.mock()
        let index = try #require(config.features.firstIndex { $0.icon != nil })
        config.features[index].iconData = Data([1, 2, 3])
        return config
    }

    @Test func cachesFeatureIcons() throws {
        let config = try makeConfigWithIcon()
        try cache.save(EventStore(config))

        #expect(try #require(cache.load()).config == config)
    }

    @Test func restoredEventIsStale() throws {
        #expect(!EventStore(.mock()).isStale)
        try cache.save(EventStore(.mock()))

        #expect(try #require(cache.load()).isStale)
    }

    @MainActor
    @Test func refreshKeepsLoadedIcons() throws {
        let config = try makeConfigWithIcon()
        try cache.save(EventStore(config))
        let event = try #require(cache.load())

        event.update(.mock())

        #expect(!event.isStale)
        #expect(event.config == config)
    }
}
