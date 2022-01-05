//
//  Player.swift
//  Word Bomb
//
//  Created by Brandon Thio on 28/6/21.
//  Copyright © 2021 Brandon Thio. All rights reserved.
//

import Foundation
import SwiftUI

class Player: Codable, Equatable, Identifiable {
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
    var name:String
    var image: Data? = nil
    var id = UUID()
    var queueNumber: Int
    
    var score = 0
    var chargeProgress = 0
    var multiplier = 1
    
    var originalTotalLives: Int
    var totalLives: Int
    var livesLeft: Int
    
    var usedLetters = Set<String>()
    
    init(name:String, queueNumber: Int) {
        self.name = name
        self.queueNumber = queueNumber
        
        let settings = Game.Settings()
        originalTotalLives = settings.playerLives
        totalLives = settings.playerLives
        livesLeft = settings.playerLives
    }
    
    func setScore(with score: Int) {
        
        let multiplier = self.multiplier
        
        self.score += score * multiplier
        self.chargeProgress += score * multiplier
        
        if self.chargeProgress >= Game.getMaxCharge(for: multiplier) {
            self.multiplier = min(3, multiplier + 1)
            self.chargeProgress -= Game.getMaxCharge(for: multiplier)
        }
    }
    
    func setImage(_ image:UIImage?) {
        self.image = image?.pngData()
    }
    
    func reset(with queueNumber: Int) {
        score = 0
        chargeProgress = 0
        livesLeft = originalTotalLives
        totalLives = originalTotalLives
        self.queueNumber = queueNumber
    }
}

