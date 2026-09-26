//
//  PushTopicManager.swift
//  OPass
//
//  Created by Brian Chang on 2026/9/25.
//  2026 OPass.
//

import FirebaseMessaging
import Foundation
import OSLog

private let logger = Logger(subsystem: "OPassData", category: "PushTopicManager")

@MainActor
final class PushTopicManager {
    static let shared = PushTopicManager(
        fileURL: .applicationSupportDirectory.appending(path: "PushTopics.json"),
        subscribe: { topic in
            try await firebaseTopicCall { Messaging.messaging().subscribe(toTopic: topic, completion: $0) }
        },
        unsubscribe: { topic in
            try await firebaseTopicCall { Messaging.messaging().unsubscribe(fromTopic: topic, completion: $0) }
        }
    )

    /// Push state of one event on this installation.
    struct EventState: Codable, Equatable {
        /// Role verified by the event service on this installation; `nil` once signed out.
        var role: String?
        /// Topic confirmed as subscribed.
        var applied: String?
        /// Topics that may be subscribed but are not confirmed, e.g. after an interrupted transition.
        var pending: Set<String> = []
    }

    private(set) var states: [String: EventState] = [:]
    private var isRegistered = false
    private var syncTasks: [String: Task<Void, Never>] = [:]
    private let fileURL: URL
    private let subscribe: @MainActor (String) async throws -> Void
    private let unsubscribe: @MainActor (String) async throws -> Void

    init(
        fileURL: URL,
        subscribe: @escaping @MainActor (String) async throws -> Void,
        unsubscribe: @escaping @MainActor (String) async throws -> Void
    ) {
        self.fileURL = fileURL
        self.subscribe = subscribe
        self.unsubscribe = unsubscribe
        if let data = try? Data(contentsOf: fileURL) {
            states = (try? JSONDecoder().decode([String: EventState].self, from: data)) ?? [:]
        }
    }

    /// Records the role the event service verified on this installation (`nil` after sign-out) and syncs that event.
    func setRole(_ role: String?, for eventId: String) {
        guard role != nil || states[eventId] != nil else { return }
        states[eventId, default: EventState()].role = role
        save()
        sync(eventId)
    }

    /// Called whenever Firebase Messaging completes or refreshes the FID registration.
    func registrationDidUpdate() {
        isRegistered = true
        syncAll()
    }

    /// Reconciles every signed-in event, not only the one on screen.
    func syncAll() {
        states.keys.forEach(sync)
    }

    /// Waits until all queued syncs finish.
    func waitForSyncs() async {
        for task in syncTasks.values { await task.value }
    }

    /// Queues a sync behind the previous SDK operations of the same event.
    private func sync(_ eventId: String) {
        // Topic APIs are only called once the FCM registration is done.
        guard isRegistered else { return }
        let previous = syncTasks[eventId]
        syncTasks[eventId] = Task {
            await previous?.value
            await apply(eventId)
        }
    }

    /// Moves the event to its target topic: unsubscribes every other topic first, then subscribes.
    private func apply(_ eventId: String) async {
        guard let state = states[eventId] else { return }
        // The localization the app actually displays, so a language change applies on the next launch.
        let locale = Self.pushLocale(for: Bundle.main.preferredLocalizations.first ?? "en")
        let target = state.role.flatMap { Self.topic(eventId: eventId, role: $0, locale: locale) }
        // Skip only when this installation already confirmed the same topic.
        if state.pending.isEmpty && state.applied == target { return }

        // Persist every topic that may end up subscribed before calling the SDK,
        // so an interrupted transition is cleaned up by a later sync.
        var topics = state.pending
        if let applied = state.applied { topics.insert(applied) }
        if let target { topics.insert(target) }
        states[eventId]?.applied = nil
        states[eventId]?.pending = topics
        save()

        do {
            for topic in topics.sorted() where topic != target {
                try await unsubscribe(topic)
                states[eventId]?.pending.remove(topic)
                save()
                logger.info("Unsubscribed from \(topic)")
            }
            if let target {
                try await subscribe(target)
                states[eventId]?.pending.remove(target)
                states[eventId]?.applied = target
                save()
                logger.info("Subscribed to \(target)")
            }
        } catch {
            logger.error("Failed to sync push topic of \(eventId): \(error.localizedDescription)")
        }
    }

    /// Stored in a file excluded from backup, so iCloud or a restored backup can never mark a new installation as subscribed.
    private func save() {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try JSONEncoder().encode(states).write(to: fileURL, options: .atomic)
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var url = fileURL
            try url.setResourceValues(values)
        } catch {
            logger.error("Failed to save push topic states: \(error.localizedDescription)")
        }
    }
}

extension PushTopicManager {
    /// `nil` when the event ID or role isn't a valid topic segment, or the role is the reserved `all`.
    nonisolated static func topic(eventId: String, role: String, locale: String) -> String? {
        let segment = #/[A-Za-z0-9_-]{1,64}/#
        guard eventId.wholeMatch(of: segment) != nil, role.wholeMatch(of: segment) != nil, role != "all" else {
            return nil
        }
        return "opass-v1.\(eventId).\(role).\(locale)"
    }

    /// Chinese and Taiwanese Hokkien UI languages get `zh-Hant` pushes, every other language gets `en`.
    nonisolated static func pushLocale(for language: String) -> String {
        let subtags = language.lowercased().split(whereSeparator: { $0 == "-" || $0 == "_" })
        if subtags.first == "zh" { return "zh-Hant" }
        // This app's bare `nan` localization is written in Han characters, i.e. `nan-Hant`.
        if subtags.first == "nan", subtags.count == 1 || ["hant", "latn"].contains(subtags[1]) { return "zh-Hant" }
        return "en"
    }

    /// Calls a Firebase topic API on the main thread and waits for its completion.
    private static func firebaseTopicCall(_ call: (@escaping @Sendable (Error?) -> Void) -> Void) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            call { error in
                if let error { continuation.resume(throwing: error) } else { continuation.resume() }
            }
        }
    }
}
