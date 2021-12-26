//
//  Defaults.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/7/21.
//

import Foundation
import SwiftUI
import AVFoundation

struct Device {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}


struct Game {
    
    static var viewModel = WordBombGameViewModel()
    static var errorHandler = ErrorViewModel()
    
    static let countries = loadWords("countries")
    static let dictionary = loadWords("words")
    static let syllables = loadSyllables("syllables_2")
    
    static let playerAvatarSize = Device.width/3.5
    
    static let bombSize = Device.width*0.4
    
    static let miniBombSize = Device.width*0.2
    
    static let miniBombExplosionOffset = CGFloat(10.0)
    
    static let explosionDuration = 0.8
    
    static var timer: Timer? = nil
    
    static func stopTimer() {
        Game.timer?.invalidate()
        Game.timer = nil
        print("Timer stopped")
    }
    
    static let mainAnimation = Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
    static func mainButton(label: String, systemImageName: String? = nil, image: AnyView? = nil, sound: String = "pop", action: @escaping () -> Void) -> some View {
        
        return Button(action: {
            Game.playSound(file: sound)
            action()
        }) {
            HStack {
                if let systemName = systemImageName {
                    Image(systemName: systemName)
                }
                else if let image = image {
                    image
                }
                Text(label)
                    
            }
        }
        .buttonStyle(MainButtonStyle())
        
    }
    
    static func backButton(action: @escaping () -> Void) -> some View {
        Button(action: {
            Game.playSound(file: "back")
            action()
        }) {
            Image(systemName: "arrow.backward")
                .font(Font.title.bold())
                .foregroundColor(.white)
        }
    }
    
    
    static var audioPlayer:AVAudioPlayer?
    static var soundTrackPlayer:AVAudioPlayer?
    static func playSoundTrack(file: String, delay: Double = 0.5) {
        
        Game.soundTrackPlayer?.setVolume(0, fadeDuration: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let path = Bundle.main.path(forResource: file, ofType: "mp3") {
                Game.soundTrackPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                
                // wait for previous sound track to fade out
                Game.soundTrackPlayer?.prepareToPlay()
                Game.soundTrackPlayer?.play()
                // Negative value for infinite loop
                Game.soundTrackPlayer?.numberOfLoops = -1
            }
        }
    }
    
    static func playSound(file: String, type: String = "wav") {
        
        if let path = Bundle.main.path(forResource: file, ofType: type) {
            do {
                
                Game.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                Game.audioPlayer?.prepareToPlay()
                Game.audioPlayer?.play()
                Game.audioPlayer?.volume = 0.3
                
            } catch let error {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
    }
}
