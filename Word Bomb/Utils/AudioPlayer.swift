//
//  AudioPlayer.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import Foundation
import AVFoundation

enum Sound {
    case Explosion
    case RunningOutOfTime
    case Select
    case Cancel
    case Banner
    case Alert
    case Correct
    case Wrong
    case Victory
    case BGMusic
    case GamePlayMusic
    
    var info: (filename: String, volume: Float) {
        switch self {
        case .Explosion:
            return ("explosion", 0.2)
        case .RunningOutOfTime:
            return ("hissing", 0.1)
        case .Select:
            return ("pop", 0.2)
        case .Cancel:
            return ("back", 0.2)
        case .Banner:
            return ("ping", 0.6)
        case .Alert:
            return ("alert", 0.5)
        case .Correct:
            return ("correct", 0.4)
        case .Wrong:
            return ("wrong-2", 0.4)
        case .Victory:
            return ("victory", 0.4)
        case .BGMusic:
            return ("Bicycle", 0.5)
        case .GamePlayMusic:
            return ("Monkeys-Spinning-Monkeys", 0.5)
        }
    }
}

class AudioPlayer {
    
    private var player = AVAudioPlayer()
    
    var volume: Float
    
    /// Useful to control the playback of ROOT sound when `timeLeft` is low. The sound can only be played when `isReady` is true.
    var isReady = true
    
    var isPlaying: Bool { player.isPlaying }
    var duration: Double { player.duration }
    
    init(sound: Sound, type: String = "wav", numLoops: Int = 0) {
        self.volume = sound.info.volume
        
        if let path = Bundle.main.path(forResource: sound.info.filename, ofType: type) {
            do {
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                // Negative value for infinite loop
                player.numberOfLoops = numLoops
                // wait for previous sound track to fade out
                player.prepareToPlay()
                player.setVolume(volume, fadeDuration: 0)
                
            } catch {
                print("Error initing AudioPlayer: \(error.localizedDescription)")
            }
        }
    }
    
    func play(with fadeDuration: Double = 0) {
        player.setVolume(0, fadeDuration: TimeInterval(fadeDuration))
        player.play()
        player.setVolume(volume, fadeDuration: TimeInterval(fadeDuration))
    }
    func pause(with fadeDuration: Double = 0, reset: Bool = false) {
        player.setVolume(0, fadeDuration: TimeInterval(fadeDuration))
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + fadeDuration) {
            self.player.pause()
            if reset {
                self.player.currentTime = 0
            }
        }
    }
    
    func toggle(with fadeDuration: Double = 0) {
        if isPlaying {
            pause(with: fadeDuration)
        } else {
            play(with: fadeDuration)
        }
    }
}

extension AudioPlayer {
    static var shared: AudioPlayer? = nil
    
    static func playSound(_ sound: Sound, type: String = "wav") {
        
        AudioPlayer.shared = AudioPlayer(sound: sound, type: type)
        AudioPlayer.shared?.play()
        
        if AudioPlayer.root.isPlaying {
            // Pause the root sound momentarily while the current sound plays
            AudioPlayer.root.pause(reset: true)
            
            // Updating on the main queue will block the UI!
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + AudioPlayer.shared!.duration) {
                // The sound can only be played once the previous sound has ended
                AudioPlayer.root.isReady = true
            }
        }
    }
    
    static var soundTrack: AudioPlayer? = nil
    
    static func playSoundTrack(_ sound: Sound, delay: Double = 1) {
        AudioPlayer.soundTrack?.pause(with: delay)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            AudioPlayer.soundTrack = AudioPlayer(sound: sound, type: "mp3", numLoops: -1)
            AudioPlayer.soundTrack?.play(with: delay)
        }
    }
    
    static var root: AudioPlayer = AudioPlayer(sound: .RunningOutOfTime)
    
    static func playROOTSound() {
        // This function is continuously called when `timeleft < 3`. We do not want the sound to keep replaying.
        guard !AudioPlayer.root.isPlaying && AudioPlayer.root.isReady else { return }
        AudioPlayer.root.play()
        AudioPlayer.root.isReady = false
    }
}
