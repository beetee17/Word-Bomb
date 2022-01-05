//
//  Enums.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/7/21.
//

import Foundation

enum DBType: String, CaseIterable {
    case Words = "Words"
    case Queries = "Queries"
}

enum InputStatus: String, Codable {
    case Correct = " is Correct"
    case Wrong = " is Wrong"
    case Used = " Already Used"
}

enum GameType: String, CaseIterable, Codable {
    case Classic = "Classic"
    case Exact = "Exact"
    case Reverse = "Reverse"
    
}

enum GameState: String, Codable {
    case Initial, PlayerInput, PlayerTimedOut, GameOver, TieBreak, Playing
}


enum ViewToShow: String, Codable {
    case Main, GameTypeSelect, ModeSelect, Game, PauseMenu, Waiting
}
