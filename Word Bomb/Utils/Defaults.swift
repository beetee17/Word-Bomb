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
    
    static let playerAvatarSize = Device.width/3.7
    
    static let bombSize = Device.width*0.4
    
    static let miniBombSize = Device.width*0.2
    
    static let miniBombExplosionOffset = CGFloat(10.0)
    
    static let explosionDuration = 1.3
    
    static func getMaxCharge(for multiplier: Int) -> Int {
        switch multiplier {
        case 1:
            return 50
        case 2:
            return 100
        case 3:
            return 200
        default:
            return 500
        }
    }
    
    static var timer: Timer? = nil
    
    static func stopTimer() {
        Game.timer?.invalidate()
        Game.timer = nil
        print("Timer stopped")
    }
}
