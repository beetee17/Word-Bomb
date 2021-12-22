//
//  Enums.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/7/21.
//

import Foundation

enum DBType: String, CaseIterable {
    case words = "Words"
    case queries = "Queries"
}

enum InputStatus: String, Codable {
    case Correct
    case Wrong
    case Used
    
    func outputText(_ input: String) -> String {
        switch self {
        
        case .Correct:
            return "\(input) is Correct"
        case .Wrong:
            return "\(input) is Wrong"
        case .Used:
            return "Already used \(input)"
        }
    }
}

enum GameType: String, CaseIterable, Codable {
    case Classic = "Classic"
    case Exact = "Exact"
    case Reverse = "Reverse"
    
}

enum GameState: String, Codable {
    case initial, playerInput, playerTimedOut, gameOver, paused, playing
}


enum ViewToShow: String, Codable {
    case main, gameTypeSelect, modeSelect, game, pauseMenu, GKMain, GKLogin
}
