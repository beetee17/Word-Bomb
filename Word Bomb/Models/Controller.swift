//
//  Media.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import Foundation

struct Controller: Codable {
    /// Controls when the explosion animation is run. Should be true when a player runs out of time
    var animateExplosion = false
    
    /// The amount of time left for the current player.
    var timeLeft: Float
    
    // The time allowed for each player, as per the host's settings. The limit may decrease with each turn depending on the other relevant settings
    var timeLimit: Float
    var originalTimeLimit: Float
    
    var timeMultiplier: Float?
    
    var timeConstraint: Float
    
    init(settings: Game.Settings = Game.Settings()) {
        timeLeft = settings.timeLimit
        timeLimit = settings.timeLimit
        originalTimeLimit = settings.timeLimit
        timeMultiplier = settings.timeMultiplier
        timeConstraint = settings.timeConstraint
    }
    /// Updates the time limit based on the the `"Time Multiplier"` and `"Time Constraint"` settings
    mutating func updateTimeLimit() {
        if let timeMultiplier = timeMultiplier {
            timeLimit = max(timeConstraint, timeLimit * timeMultiplier)
            print("time multiplied")
            timeLeft = timeLimit
        } 
    }
    
    mutating func addTime(_ amount: Float) {
        timeLeft += amount
        timeLimit = max(timeLimit, timeLeft)
        
    }
    
    
    mutating func playExplosion() {
        animateExplosion = true
        AudioPlayer.playSound(.Explosion)
    }
    
    mutating func reset() {
        timeLeft = originalTimeLimit
        timeLimit = originalTimeLimit
        animateExplosion = false
    }
}
