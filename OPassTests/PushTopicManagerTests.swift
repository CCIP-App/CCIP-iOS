//
//  PushTopicManagerTests.swift
//  OPassTests
//
//  Created by Brian Chang on 2026/9/25.
//  2026 OPass.
//

import Foundation
import Testing
@testable import OPass

struct PushTopicTests {
    @Test(arguments: ["zh-Hant", "zh-Hans", "zh", "zh-TW", "zh_Hant_TW", "nan", "nan-Hant-TW", "nan-Latn-TW", "NAN-HANT"])
    func chineseAndTaiwaneseUseTraditionalChinese(language: String) {
        #expect(PushTopicManager.pushLocale(for: language) == "zh-Hant")
    }

    @Test(arguments: ["en", "en-US", "ja", "ko", "id", "hi", "ta", "nb", ""])
    func otherLanguagesFallBackToEnglish(language: String) {
        #expect(PushTopicManager.pushLocale(for: language) == "en")
    }

    @Test func buildsGatewayTopic() {
        #expect(PushTopicManager.topic(eventId: "SITCON_2027", role: "audience", locale: "zh-Hant") == "opass-v1.SITCON_2027.audience.zh-Hant")
        #expect(PushTopicManager.topic(eventId: String(repeating: "a", count: 64), role: "staff-1", locale: "en") != nil)
    }

    @Test(arguments: [
        ("SITCON_2027", "all"),
        ("SITCON_2027", ""),
        ("SITCON_2027", "staff member"),
        ("SITCON_2027", "audience\n"),
        ("SITCON.2027", "audience"),
        ("SITCON_2027", "講者"),
        (String(repeating: "a", count: 65), "audience"),
    ])
    func rejectsInvalidSegments(eventId: String, role: String) {
        #expect(PushTopicManager.topic(eventId: eventId, role: role, locale: "en") == nil)
    }
}

@MainActor
struct PushTopicSyncTests {
    /// Records SDK calls as `+topic` / `-topic`.
    final class FakeMessaging {
        var calls: [String] = []
        /// Simulates the app being killed after the SDK subscribed but before the success was saved.
        var failSubscribe = false

        func subscribe(_ topic: String) throws {
            calls.append("+\(topic)")
            if failSubscribe { throw CancellationError() }
        }

        func unsubscribe(_ topic: String) throws {
            calls.append("-\(topic)")
        }
    }

    let file = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).json")
    let sdk = FakeMessaging()

    func makeManager() -> PushTopicManager {
        PushTopicManager(
            fileURL: file,
            subscribe: { [sdk] in try sdk.subscribe($0) },
            unsubscribe: { [sdk] in try sdk.unsubscribe($0) })
    }

    func topic(_ role: String, event eventId: String = "SITCON_2027") -> String {
        let locale = PushTopicManager.pushLocale(for: Bundle.main.preferredLocalizations.first ?? "en")
        return PushTopicManager.topic(eventId: eventId, role: role, locale: locale)!
    }

    @Test func subscribesOnlyAfterRegistration() async {
        let manager = makeManager()
        manager.setRole("audience", for: "SITCON_2027")
        await manager.waitForSyncs()
        #expect(sdk.calls.isEmpty)

        manager.registrationDidUpdate()
        await manager.waitForSyncs()
        #expect(sdk.calls == ["+\(topic("audience"))"])
        #expect(manager.states["SITCON_2027"] == .init(role: "audience", applied: topic("audience")))
    }

    @Test func roleChangeUnsubscribesOldTopicFirst() async {
        let manager = makeManager()
        manager.registrationDidUpdate()
        manager.setRole("audience", for: "SITCON_2027")
        await manager.waitForSyncs()
        sdk.calls = []

        manager.setRole("staff", for: "SITCON_2027")
        await manager.waitForSyncs()
        #expect(sdk.calls == ["-\(topic("audience"))", "+\(topic("staff"))"])
        #expect(manager.states["SITCON_2027"] == .init(role: "staff", applied: topic("staff")))
    }

    @Test func appliedTopicIsNotSubscribedAgain() async {
        let manager = makeManager()
        manager.registrationDidUpdate()
        manager.setRole("audience", for: "SITCON_2027")
        await manager.waitForSyncs()
        sdk.calls = []

        manager.setRole("audience", for: "SITCON_2027")
        manager.registrationDidUpdate()
        await manager.waitForSyncs()
        #expect(sdk.calls.isEmpty)
    }

    @Test func signOutOnlyRemovesThatEvent() async {
        let manager = makeManager()
        manager.registrationDidUpdate()
        manager.setRole("audience", for: "SITCON_2027")
        manager.setRole("staff", for: "COSCUP_2026")
        await manager.waitForSyncs()
        sdk.calls = []

        manager.setRole(nil, for: "SITCON_2027")
        await manager.waitForSyncs()
        #expect(sdk.calls == ["-\(topic("audience"))"])
        #expect(manager.states["SITCON_2027"] == .init(role: nil, applied: nil))
        #expect(manager.states["COSCUP_2026"]?.applied == topic("staff", event: "COSCUP_2026"))
    }

    @Test func reservedRoleIsNeverSubscribed() async {
        let manager = makeManager()
        manager.registrationDidUpdate()
        manager.setRole("all", for: "SITCON_2027")
        await manager.waitForSyncs()
        #expect(sdk.calls.isEmpty)
    }

    @Test func interruptedTransitionIsCleanedUpAfterRelaunch() async {
        sdk.failSubscribe = true
        let manager = makeManager()
        manager.registrationDidUpdate()
        manager.setRole("audience", for: "SITCON_2027")
        await manager.waitForSyncs()
        #expect(manager.states["SITCON_2027"] == .init(role: "audience", applied: nil, pending: [topic("audience")]))

        // Relaunch; the role changed before the SDK confirmed the old topic.
        sdk.failSubscribe = false
        sdk.calls = []
        let relaunched = makeManager()
        relaunched.setRole("staff", for: "SITCON_2027")
        relaunched.registrationDidUpdate()
        await relaunched.waitForSyncs()
        #expect(sdk.calls == ["-\(topic("audience"))", "+\(topic("staff"))"])
        #expect(relaunched.states["SITCON_2027"] == .init(role: "staff", applied: topic("staff")))
    }

    @Test func stateFileIsExcludedFromBackup() throws {
        let manager = makeManager()
        manager.setRole("audience", for: "SITCON_2027")
        let values = try file.resourceValues(forKeys: [.isExcludedFromBackupKey])
        #expect(values.isExcludedFromBackup == true)
    }
}
