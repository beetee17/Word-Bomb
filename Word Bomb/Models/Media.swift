//
//  Media.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import Foundation

struct Media: Codable {
    /// Controls when the explosion animation is run. Should be true when a player runs out of time
    var animateExplosion = false
    
    /// Controls the playback of the sound when `timeLeft` is low. Should be set to false after each turn.
    var playRunningOutOfTimeSound = false
    
    mutating func resetROOTSound() {
        playRunningOutOfTimeSound = false
    }
    
    mutating func playExplosion() {
        animateExplosion = true
        Game.playSound(file: "explosion")
    }
    
    mutating func reset() {
        animateExplosion = false
        playRunningOutOfTimeSound = false
    }
}
