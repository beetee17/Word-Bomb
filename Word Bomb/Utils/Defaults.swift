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
    
    /// check out https://stackoverflow.com/questions/38454952/map-array-of-objects-to-dictionary-in-swift for more info
    static let words = dictionary.reduce(into: [String: [String]]()) { $0[$1.first!] = [$1.first!] }
    
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
            return 750
        }
    }
    static func getFrequencyScore(_ frequency: Int) -> Float {
        switch frequency {
        case 0...25:
            return 25
        case 26...100:
            return 15
        case 101...200:
            return 10
        case 201...500:
            return 5
        case 501...1000:
            return 3
        default:
            return 1
        }
    }
    
    static func getInputMultiplier(_ input: String) -> Float {
        switch input.trim().count {
        case 0...3:
            return 1
        case 4:
            return 1.5
        case 5:
            return 2
        case 6...7:
            return 2.5
        case 8...10:
            return 3
        default:
            return 5
        }
    }
    
    static var timer: Timer? = nil
    
    static func stopTimer() {
        Game.timer?.invalidate()
        Game.timer = nil
        print("Timer stopped")
    }
}


extension Game {
    struct Settings: Codable {
        var timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
        var timeConstraint = UserDefaults.standard.float(forKey:"Time Constraint")
        var timeMultiplier: Float? = UserDefaults.standard.float(forKey: "Time Multiplier")
        var playerLives = UserDefaults.standard.integer(forKey: "Player Lives")
        var numTurnsBeforeNewQuery = 2
    }
}
