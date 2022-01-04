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

struct Players: Codable {
    
    /**
     Mutating array of `Player` objects that provides information about the current sequence of players.
     
     The order of objects in the`queue` is modified after each turn; it follows a carousel-like structure.
     `Player` objects are removed from the `queue` when they run out of lives
     */
    var queue: [Player]
    
    var playing: [Player] { queue.filter({ $0.livesLeft > 0 })}
    
    /// The `Player` object representing the current player in the game
    var current: Player
    
    var totalLives: Int {
        current.totalLives
    }
    
    /// Initialises with an optional array of `Player` objects
    /// - Parameter players: if `players` is nil, fallback to the user settings for the number of players and the names of each player
    init(from players: [Player]? = nil) {
        
        if let players = players, !players.isEmpty {
            self.queue = players
        }
        else {
            self.queue = []
            let playerNames = UserDefaults.standard.stringArray(forKey: "Player Names") ?? []

            for i in 0..<max(1, UserDefaults.standard.integer(forKey: "Num Players")) {
                
                if i >= playerNames.count {
                    // If no name was set by the user for this player, create one with a generic name
                    self.queue.append(Player(name: "Player \(i+1)", queueNumber: i))
                }
                else {
                    self.queue.append(Player(name: playerNames[i], queueNumber: i))
                }
            }
            
        }
        self.current = queue.first!
    }
    
    init(from playerNames: [String]) {
        
        var players: [Player] = []
        for i in playerNames.indices {
            players.append(Player(name: playerNames[i], queueNumber: i))
        }
        self.init(from: players)
    }
    
    mutating func updateCurrentPlayer() {
        if let newCurrent = queue.first(where: ({ $0.queueNumber == 0 })) {
            print("Current player changed from \(current.name) to \(newCurrent.name)")
            current = newCurrent
        }
    }
    
    /// Removes `player` from the game. Should be called in multiplayer context if `player` disconnects
    /// - Parameter player: `Player` object to be removed
    mutating func remove(_ player: Player) {
        guard let index = queue.firstIndex(of: player) else { return }
        
        
        queue.remove(at: index)
        print("Player removed")
        
        for activePlayer in queue {
            if activePlayer.queueNumber > player.queueNumber {
                // shift everyone behind the removed player down by one
                activePlayer.queueNumber -= 1
            }
        }
    }
    
    /// Updates `current` and `queue`  when `current` runs out of time
    /// - Returns: Tuple containing the output text to be displayed, and a Boolean corresponding to if the game is over
    mutating func currentPlayerRanOutOfTime() -> (String, Bool) {
        
        var output = ""
        
        for player in queue {
            print("\(player.name): \(player.livesLeft) lives")
        }
        
        switch current.livesLeft == 0 {
        case true:
            output = "\(current.name) Ran Out of Lives!"
        case false:
            output = "\(current.name) Ran Out of Time!"
        }
        
        let currPlayer = nextPlayer()
        currPlayer.livesLeft -= 1
        
        return (output, playing.count == 0)

    }
    
    /// Should only be called when game is over
    /// Assigns the `current` `Player` to the player that has the highest score
    /// If multiple players have the same high score, lives left should decide the winner
    /// What if multiple players have same score and lives left? Just choose first player...
    mutating func getWinningPlayer() {
        let winningScore = queue.max(by: { $0.score < $1.score })?.score
        print("The winning score was \(String(describing: winningScore))")
        
        let winningPlayers = queue.filter({ $0.score == winningScore })
        print("The players with such a score are \(winningPlayers)")
        
        if let winningPlayer = winningPlayers.max(by: { $0.livesLeft < $1.livesLeft }) {
            print("THE WINNING PLAYER IS \(winningPlayer.name)")
            current = winningPlayer
        }
    }
    
    /// Goes to the next `Player` in the `queue` and updates `current`; following a carousel-like structure
    /// - Returns: `Player` object corresponding to `current` *before* the update was made
    mutating func nextPlayer() -> Player {

        let prev = current
        
        switch playing.count {
        case 1:
            break
        case 2:
//            print("2 player swap, \(playing.first?.name): \(playing.first?.queueNumber) and \(playing.last?.name): \(playing.last?.queueNumber)")
            if current == playing.first! {
                playing.last!.queueNumber = 0
                playing.first!.queueNumber = 1
            } else {
                playing.first!.queueNumber = 0
                playing.last!.queueNumber = 1
            }
//            print("2 player swap complete, \(playing.first?.name): \(playing.first?.queueNumber) and \(playing.last?.name): \(playing.last?.queueNumber)")
        default:
            // cycle current player to back of queue
            print("\(current.name) with \(current.livesLeft) lives left going to back of queue")
            
            for i in playing.indices {
                if playing[i].queueNumber == 0 {
                    playing[i].queueNumber = playing.count-1
                } else {
                    playing[i].queueNumber -= 1
                }
            }
        }
        
        updateCurrentPlayer()
        
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
    
    mutating func reset() {
        for i in queue.indices {
            queue[i].reset(with: i)
        }
        updateCurrentPlayer()
    }
}
