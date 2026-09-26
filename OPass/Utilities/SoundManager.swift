//
//  SoundManager.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/10.
//  2025 OPass.
//

import Foundation
import AVFAudio
import OSLog

private let logger = Logger(subsystem: "app.opass.ccip", category: "SoundManager")

final class SoundManager: @unchecked Sendable {
    static let shared = SoundManager()

    enum SoundOption: String, CaseIterable {
        case din
        case don
    }

    private let queue = DispatchQueue(label: "app.opass.ccip.SoundManager")
    private var players: [SoundOption: AVAudioPlayer] = [:]

    func initialize() {
        queue.async { [self] in
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient)
            } catch {
                logger.error("Error when initializing SoundManager due to: \(error.localizedDescription)")
            }
            for sound in SoundOption.allCases {
                guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { continue }
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players[sound] = player
                } catch {
                    logger.error("Error when loading sound \(sound.rawValue) due to: \(error.localizedDescription)")
                }
            }
        }
    }

    func play(sound: SoundOption) {
        queue.async { [self] in
            players.values.filter(\.isPlaying).forEach { $0.pause() }
            players[sound]?.currentTime = 0
            players[sound]?.play()
        }
    }
}
