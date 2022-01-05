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
    
    var totalLives = UserDefaults.standard.integer(forKey: "Player Lives")
    var livesLeft = UserDefaults.standard.integer(forKey: "Player Lives")
    
    var usedLetters = Set<String>()
    
    init(name:String, queueNumber: Int) {
        self.name = name
        self.queueNumber = queueNumber
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
        livesLeft = totalLives
        self.queueNumber = queueNumber
    }
}

