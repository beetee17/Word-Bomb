//
//  Multiplayer.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/7/21.
//

import Foundation

struct Multiplayer {
    static func send(_ data: GameData, toHost: Bool = false) {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(data)
            GameCenter.send(jsonData, toHost: toHost)
        }
        catch {
            print(String(describing: error))
        }
    }
}

struct GameData: Codable {
    var state: GameState?
    var model: WordBombGame?
    var input: String?
    var response: InputStatus?
    var query: String?
    var timeLeft: Float?
    var timeLimit: Float?
    var playerLives: [String:Int]?
    
    public func process() {
        if let model = self.model {
            DispatchQueue.main.async {
                print("Got model from host!")
                
                Game.viewModel.setSharedModel(model)
                
                for player in Game.viewModel.playerQueue {
                    print("\(player.name): \(player.livesLeft) lives")
                }
                Game.viewModel.viewToShow = .game
                Game.viewModel.startTimer()
                if let match = GameCenter.viewModel.gkMatch {
                    Game.viewModel.setGKPlayerImages(match.players)
                } else { print("No GKMatch found??") }
            }
        }
        else if let gameState = self.state {
            switch gameState {
                
            case .initial:
                break
            case .playerInput:
                print("received input response from host")
                let nilString: String? = nil
                Game.viewModel.handleGameState(gameState,
                                               data: ["input" : self.input!,
                                                      "response" : (self.response!, nilString)])
            case .playerTimedOut:
                Game.viewModel.handleGameState(gameState)
            case .gameOver:
                break
            case .paused:
                Game.stopTimer()
            case .playing:
                Game.viewModel.startTimer()
            }
        }
        else if let updatedPlayers = self.playerLives {
            print("Received updated playerQueue from host ")
            Game.viewModel.updatePlayerLives(updatedPlayers)
            print("Updated player queue")
        }
        else if let query = self.query {
            print("received new query from host \(query)")
            Game.viewModel.query = query
        }
        else if let input = self.input {
            print("Got data from non-host device ! \(input)")
            Game.viewModel.processNonHostInput(input)
        }
        else if let timeLeft = self.timeLeft {
            print("received updated time left from host \(timeLeft)")
            Game.viewModel.timeLeft = timeLeft
        }
        
        else if let timeLimit = self.timeLimit {
            print("receive new time limit from host \(timeLimit)")
            Game.viewModel.timeLeft = timeLimit
        }
    }
    
}
