//
//  SoundManager.swift
//  OPass
//
//  Created by 張智堯 on 2022/5/10.
//

import Foundation
import AVFAudio
import OSLog

class SoundManager {
    private let logger = Logger(subsystem: "app.opass.ccip", category: "SoundManager")
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    enum SoundOption: String {
        case din
        case don
    }
    
    func play(sound: SoundOption) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            logger.error("Error playing sound: \(error.localizedDescription)")
        }
    }
}
