//
//  SoundManager.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/10.
//  2023 OPass.
//

import Foundation
import AVFAudio
import OSLog

private let logger = Logger(subsystem: "app.opass.ccip", category: "SoundManager")

class SoundManager: NSObject {
    static let shared = SoundManager()

    private var audioSession = AVAudioSession.sharedInstance()
    private var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case din
        case don
    }

    func initialize() {
        do {
            try audioSession.setCategory(.ambient, options: .duckOthers)
            try audioSession.setActive(false)
        } catch {
            logger.error("Error when initializing SoundManager due to: \(error.localizedDescription)")
        }
    }
    
    func play(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do {
            player = try .init(contentsOf: url)
            player?.delegate = self
            try audioSession.setActive(true)
            player?.play()
        } catch {
            logger.error("Error when playing sound due to: \(error.localizedDescription)")
        }
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.global().async {
            do {
                try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                logger.error("Error when deactivating AudioSession due to: \(error.localizedDescription)")
            }
        }
    }
}
