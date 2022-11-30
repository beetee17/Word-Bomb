//
//  Player.swift
//  Word Bomb
//
//  Created by Brandon Thio on 28/6/21.
//  Copyright © 2021 Brandon Thio. All rights reserved.
//

import Foundation
import SwiftUI

class Player: Codable, Equatable, Identifiable, ObservableObject {
    enum CodingKeys: CodingKey {
        case image, id, name, queueNumber, score, chargeProgress, multiplier, numTickets, originalTotalLives,totalLives, livesLeft, usedLetters
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(image, forKey: .image)
        try container.encode(id, forKey: .id)

        try container.encode(name, forKey: .name)
        try container.encode(queueNumber, forKey: .queueNumber)

        try container.encode(score, forKey: .score)
        try container.encode(chargeProgress, forKey: .chargeProgress)
        try container.encode(multiplier, forKey: .multiplier)
        try container.encode(numTickets, forKey: .numTickets)
        
        try container.encode(originalTotalLives, forKey: .originalTotalLives)
        try container.encode(totalLives, forKey: .totalLives)
        try container.encode(livesLeft, forKey: .livesLeft)
        try container.encode(usedLetters, forKey: .usedLetters)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        image = try container.decode(Data.self, forKey: .image)
        id = try container.decode(UUID.self, forKey: .id)

        name = try container.decode(String.self, forKey: .name)
        queueNumber = try container.decode(Int.self, forKey: .queueNumber)

        name = try container.decode(String.self, forKey: .score)
        chargeProgress = try container.decode(Int.self, forKey: .chargeProgress)
        multiplier = try container.decode(Int.self, forKey: .multiplier)
        numTickets = try container.decode(Int.self, forKey: .numTickets)
        
        originalTotalLives = try container.decode(Int.self, forKey: .originalTotalLives)
        totalLives = try container.decode(Int.self, forKey: .totalLives)
        livesLeft = try container.decode(Int.self, forKey: .livesLeft)
        usedLetters = try container.decode(Set<String>.self, forKey: .usedLetters)
    }
    
    static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.id == rhs.id &&
        lhs.chargeProgress == rhs.chargeProgress &&
        lhs.score == rhs.score &&
        lhs.multiplier == rhs.multiplier &&
        lhs.numTickets == rhs.numTickets &&
        lhs.totalLives == rhs.totalLives &&
        lhs.livesLeft == rhs.livesLeft &&
        lhs.usedLetters == rhs.usedLetters &&
        lhs.queueNumber == rhs.queueNumber
    }
    
    var image: Data? = nil
    var id = UUID()
    
    @Published var name: String
    @Published var queueNumber: Int
    
    @Published var score = 0
    @Published var chargeProgress = 0
    @Published var multiplier = 1
    @Published var numTickets = 1
    
    @Published var originalTotalLives: Int
    @Published var totalLives: Int
    @Published var livesLeft: Int
    
    @Published var usedLetters = Set<String>()
    
    init(name: String, queueNumber: Int) {
        self.name = name
        self.queueNumber = queueNumber
        
        let settings = Game.Settings()
        originalTotalLives = settings.playerLives
        totalLives = settings.playerLives
        livesLeft = settings.playerLives
    }
    
    func setScore(with score: Int) {
        
        let multiplier = min(3, self.multiplier)
        
        self.score += score * multiplier
        self.chargeProgress += score * multiplier
        
        if self.chargeProgress >= Game.getMaxCharge(for: self.multiplier) {
            self.chargeProgress = self.chargeProgress - Game.getMaxCharge(for: self.multiplier)
            self.multiplier += 1
            numTickets += 1
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

