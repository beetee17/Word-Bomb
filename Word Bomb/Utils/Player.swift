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
    var totalLives = UserDefaults.standard.integer(forKey: "Player Lives")
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
        livesLeft = totalLives
    }
}

class Players: Codable, Identifiable {
    
    /// Non-mutating array of `Player` objects containing every player in the current game. This allows us to reset the `queue` when restarting the game .
    var allPlayers: [Player]
    
    /**
     Mutating array of `Player` objects that provides information about the current sequence of players.
     
     The order of objects in the`queue` is modified after each turn; it follows a carousel-like structure.
     `Player` objects are removed from the `queue` when they run out of lives
     */
    var queue: [Player]
    
    /// The `Player` object representing the current player in the game
    var current: Player
    var totalLives: Int {
        current.totalLives
    }
    var numTurnsInCurrentRound = 0
    var numRounds = 1
    var numCorrect = 0
    
    /// Initialises with an optional array of `Player` objects
    /// - Parameter players: if `players` is nil, fallback to the user settings for the number of players and the names of each player
    init(from players: [Player]? = nil) {
        
        if let players = players, !players.isEmpty {
            self.allPlayers = players
        }
        else {
            self.allPlayers = []
            let playerNames = UserDefaults.standard.stringArray(forKey: "Player Names") ?? []

            for i in 0..<max(1, UserDefaults.standard.integer(forKey: "Num Players")) {
                
                if i >= playerNames.count {
                    // If no name was set by the user for this player, create one with a generic name
                    self.allPlayers.append(Player(name: "Player \(i+1)"))
                }
                else {
                    self.allPlayers.append(Player(name: playerNames[i]))
                }
            }
            
        }
        self.queue = self.allPlayers
        self.current = queue.first!
    }
    convenience init(from playerNames: [String]) {
        
        var players: [Player] = []
        for playerName in playerNames {
            players.append(Player(name: playerName))
        }
        self.init(from: players)
    }
    
    func find(_ player: Player) -> Int? {
        for i in allPlayers.indices {
            if allPlayers[i].id == player.id { return i }
        }
        return nil
    }
    
    /// Removes `player` from the game. Should be called in multiplayer context if `player` disconnects
    /// - Parameter player: `Player` object to be removed
    func remove(_ player: Player) {
        guard let index = queue.firstIndex(of: player) else { return }
        print("Player removed")
        queue.remove(at: index)
    }
    
    /// Updates `current` and `queue`  when `current` runs out of time
    /// - Returns: Tuple containing the output text to be displayed, and a Boolean corresponding to if the game is over
    func currentPlayerRanOutOfTime() -> (String, Bool) {
        
        var output = ""
        
        current.livesLeft -= 1
        
        for player in queue {
            print("\(player.name): \(player.livesLeft) lives")
        }
            
        switch current.livesLeft == 0 {
        case true:
            output = "\(current.name) Lost!"
        case false:
            output = "\(current.name) Ran Out of Time!"
        }
        
        guard queue.count != 1 else {
            // User is playing in training mode
            return ("You Ran Out of Time!", current.livesLeft == 0)
        }
        
        let currPlayer = nextPlayer()
        if currPlayer.livesLeft == 0 {
            remove(currPlayer)
        }
        
        return (output, queue.count < 2)
    }
    
    /// Goes to the next `Player` in the `queue` and updates `current`; following a carousel-like structure
    /// - Returns: `Player` object corresponding to `current` *before* the update was made
    func nextPlayer() -> Player {
        
        let prev = current
        
        switch queue.count {
        case 1:
            current = queue.first!
        case 2:
            print("2 player swap")
            current = current == queue.first! ? queue.last! : queue.first!
        default:
            // cycle current player to back of queue
            print("\(current.name) with \(current.livesLeft) lives left going to back of queue")
            queue.append(queue.dequeue()!)
            current = queue.first!
        }
        
        numTurnsInCurrentRound += 1
        if numTurnsInCurrentRound >= queue.count {
            numRounds += 1
            print("numRounds: \(numRounds)")
            numTurnsInCurrentRound = 0
        }
        
        return prev
    }
    
    /// Sets the relevant `Player` objects with the given `livesLeft`.
    /// - Parameter data: Mapping from `Player.name` to `Player.livesLeft`
    func updatePlayerLives(with data: [String:Int]) {
        for player in queue {
            print("before updated \(player.name): \(player.livesLeft) lives")
            if let updatedLives = data[player.name], player.livesLeft != updatedLives {
                player.livesLeft = updatedLives
            }
            print("updated \(player.name): \(player.livesLeft) lives")
        }
    }
    
    func reset() {
        for player in allPlayers {
            player.reset()
        }
        queue = allPlayers
        current = queue.first!
        
        numRounds = 1
        numTurnsInCurrentRound = 0
        numCorrect = 0
    }
}
