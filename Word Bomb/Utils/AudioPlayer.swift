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
    case Combo
    case Victory
    case BGMusic
    case GamePlayMusic
    
    var info: (filename: String, volume: Float) {
        switch self {
        case .Explosion:
            return ("explosion", 0.05)
        case .RunningOutOfTime:
            return ("hissing", 0.025)
        case .Select:
            return ("pop", 0.05)
        case .Cancel:
            return ("back", 0.05)
        case .Banner:
            return ("ping", 0.05)
        case .Alert:
            return ("alert", 0.05)
        case .Correct:
            return ("correct", 0.05)
        case .Wrong:
            return ("wrong-2", 0.05)
        case .Combo:
            return ("combo", 0.05)
        case .Victory:
            return ("victory", 0.05)
        case .BGMusic:
            return ("Bicycle", 0.1)
        case .GamePlayMusic:
            return ("Monkeys-Spinning-Monkeys", 0.1)
        }
    }
}

class AudioPlayer {
    
    private var player = AVAudioPlayer()
    
    var volume: Float = 0.01
    
    /// Useful to control the playback of ROOT sound when `timeLeft` is low. The sound can only be played when `isReady` is true.
    var isReady = true
    
    var isPlaying: Bool { player.isPlaying }
    var duration: Double { player.duration }
    
    init(sound: Sound, type: String = "wav", numLoops: Int = 0) {
        
        if let path = Bundle.main.path(forResource: sound.info.filename, ofType: type) {
            do {
                _ = try? AVAudioSession
                            .sharedInstance()
                            .setCategory(AVAudioSession.Category.ambient,
                                         mode: .default,
                                         options: .mixWithOthers)
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                // Negative value for infinite loop
                player.numberOfLoops = numLoops
                // wait for previous sound track to fade out
                player.prepareToPlay()
                player.setVolume(self.volume, fadeDuration: 0)
                
            } catch {
                print("Error initing AudioPlayer: \(error.localizedDescription)")
            }
        }
    }
    func setVolume(to newVolume: Float = 0.5) {
        self.volume = newVolume
    }
    
    func scaleVolume(by scale: Float = 1) {
        player.setVolume(self.volume*scale, fadeDuration: 0)
    }
    
    func play(with fadeDuration: Double = 0) {
        player.setVolume(0, fadeDuration: TimeInterval(fadeDuration))
        player.play()
        player.setVolume(self.volume, fadeDuration: TimeInterval(fadeDuration))
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
        guard UserDefaults.standard.bool(forKey: "Sound FXs") else { return }
        
        AudioPlayer.shared?.pause()
        AudioPlayer.shared = nil
        
        AudioPlayer.shared = AudioPlayer(sound: sound, type: type)
        AudioPlayer.shared?.setVolume(to: sound.info.volume*UserDefaults.standard.float(forKey: "SoundFX Volume"))
        AudioPlayer.shared?.play()
        
        if AudioPlayer.root.isPlaying {
            // Pause the root sound momentarily while the current sound plays
            AudioPlayer.root.pause(reset: true)
            
            // Updating on the main queue will block the UI!
            if let audioPlayer = AudioPlayer.shared {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + audioPlayer.duration) {
                    // The sound can only be played once the previous sound has ended
                    AudioPlayer.root.isReady = true
                }
            } else {
                AudioPlayer.root.isReady = true
            }
        }
    }
    
    static var soundTrack: AudioPlayer? = nil
    
    static func playSoundTrack(_ sound: Sound, delay: Double = 1) {
        guard UserDefaults.standard.bool(forKey: "Soundtrack") else { return }
        AudioPlayer.soundTrack?.pause(with: delay)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            AudioPlayer.soundTrack = AudioPlayer(sound: sound, type: "mp3", numLoops: -1)
            AudioPlayer.soundTrack?.setVolume(to: sound.info.volume*UserDefaults.standard.float(forKey: "Soundtrack Volume"))
            AudioPlayer.soundTrack?.play(with: delay)
        }
    }
    
    static var root: AudioPlayer = AudioPlayer(sound: .RunningOutOfTime)
    
    static func playROOTSound() {
        // This function is continuously called when `timeleft < 3`. We do not want the sound to keep replaying.
        guard UserDefaults.standard.bool(forKey: "Sound FXs") else { return }
        
        guard !AudioPlayer.root.isPlaying && AudioPlayer.root.isReady else { return }
        AudioPlayer.root.player.numberOfLoops = 1
        AudioPlayer.root.setVolume(to: Sound.RunningOutOfTime.info.volume*UserDefaults.standard.float(forKey: "SoundFX Volume"))
        AudioPlayer.root.play()
        AudioPlayer.root.isReady = false
    }
}
