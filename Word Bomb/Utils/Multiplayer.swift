//
//  Multiplayer.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/7/21.
//

import Foundation

struct GameData: Codable {
    var state: GameState?
    var model: WordBombGame?
    var input: String?
    var response: Response?
    var query: String?
    var timeLeft: Float?
    var timeLimit: Float?
    var playerLives: [String:Int]?
    var variants: [String: [String]]?
    var totalWords: Int?
    var nonHostIsReady: Bool?
    
    public func process() {
        if let model = self.model {
            DispatchQueue.main.async {
                print("Got model from host!")
                if let gameModel = Game.viewModel.model.game {
                    // do not override the game model if it arrives earlier than the shared model
                    Game.viewModel.setSharedModel(model)
                    Game.viewModel.model.game = gameModel
                } else {
                    Game.viewModel.setSharedModel(model)
                }
                for player in Game.viewModel.model.players.queue {
                    print("\(player.name): \(player.livesLeft) lives")
                }
            }
        }
        else if let gameState = self.state {
            switch gameState {
                
            case .Initial:
                Game.viewModel.viewToShow = .Game
                Game.viewModel.startTimer()
                Game.viewModel.model.game?.reset()
            case .PlayerInput:
                print("received input response from host")
                Game.viewModel.handleGameState(gameState,
                                               data: ["response" : self.response!])
            case .PlayerTimedOut:
                Game.viewModel.handleGameState(gameState)
            case .GameOver:
                break
            case .TieBreak:
                break
            case .Playing:
                Game.viewModel.startTimer()
            }
            Game.viewModel.model.gameState = gameState
        }
        else if let updatedPlayers = self.playerLives {
            print("Received updated playerQueue from host ")
            Game.viewModel.model.players.updatePlayerLives(with: updatedPlayers)
            print("Updated player queue")
        }
        else if let query = self.query {
            print("received new query from host \(query)")
            Game.viewModel.model.query = query
        }
        else if let input = self.input {
            print("Got data from non-host device ! \(input)")
            Game.viewModel.model.processNonHostInput(input)
        }
        else if let timeLeft = self.timeLeft {
            print("received updated time left from host \(timeLeft)")
            Game.viewModel.model.controller.timeLeft = timeLeft
        }
        
        else if let timeLimit = self.timeLimit {
            print("receive new time limit from host \(timeLimit)")
            Game.viewModel.model.controller.timeLimit = timeLimit
        }
        else if let variants = variants {
            if let totalWords = totalWords {
                print("received all the words from host")
                WordBombGame.getNonHostGameModel(variants, totalWords: totalWords) { gameModel in
                    Game.viewModel.model.setGameModel(with: gameModel)
                    GameCenter.send(GameData(nonHostIsReady: true), toHost: true)
                    print("set up game model!")
                }
            }
        }
        else if nonHostIsReady != nil {
            Game.viewModel.gkConnectedPlayers += 1
            print("Received ready notification from non host")
        }
    }
}
