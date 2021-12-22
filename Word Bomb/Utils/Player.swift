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
    
    var score = 0
    var name:String
    var id = UUID()
    var livesLeft = UserDefaults.standard.integer(forKey: "Player Lives")
    var image: Data? = nil
    
    init(name:String) {
        self.name = name
    }
    
    func setImage(_ image:UIImage?) {
        self.image = image?.pngData()
    }
    
    func reset() {
        score = 0
        livesLeft = UserDefaults.standard.integer(forKey: "Player Lives")
    }
}
