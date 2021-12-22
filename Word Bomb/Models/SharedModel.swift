//
//  WordBombGame.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import Foundation

struct WordBombGame: Codable {
    
    // This model is the mainModel, it implements everything that is independent of the game mode. e.g. it should not implement the processInput function as that differs depending on game mode
    
    var playerQueue: [Player]
    var players: [Player]
    
    var currentPlayer: Player
    var livesLeft = UserDefaults.standard.integer(forKey: "Player Lives")
    
    var timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
    var timeLeft = UserDefaults.standard.float(forKey: "Time Limit")

    var gameState: GameState = .initial
    
    var output = ""
    var query: String?
    var instruction = "" {
        didSet {
            print("instruction set to \(instruction)")
        }
    }
    
    var animateExplosion: Bool = false
    
    
    init(_ players: [Player]? = nil) {
        if let players = players {
            self.playerQueue = players
            
        }
        else {
            self.playerQueue = []

            let playerNames: [String] = UserDefaults.standard.stringArray(forKey: "Player Names")!

            for i in 0..<UserDefaults.standard.integer(forKey: "Num Players") {
                
                if i >= playerNames.count {
                    self.playerQueue.enqueue(Player(name: "Player \(i+1)"))
                }
                else {
                    self.playerQueue.enqueue(Player(name: playerNames[i]))
                }
            }
        }

        self.currentPlayer = self.playerQueue[0]
        self.players = self.playerQueue
    }
    
    mutating func updateTimeLimit() {
        if currentPlayer == players.first! {
            timeLimit = max(UserDefaults.standard.float(forKey:"Time Constraint"), timeLimit * UserDefaults.standard.float(forKey: "Time Multiplier"))
            print("time multiplied")
        }
        timeLeft = timeLimit
    }
    mutating func process(_ input: String, _ response: (status: InputStatus, newQuery: String?)) {
        print("handling player input")
        // reset the time for other player iff answer from prev player was correct
        
        if GameCenter.isHost {
            
            Multiplayer.send(GameData(state: .playerInput, input: input, response: response.status), toHost: false)

        }
        
        output = response.status.outputText(input)
        
        if response.status == .Correct {

            if let newQuery = response.newQuery {
                self.query = newQuery
                
                if GameCenter.isHost {
                    
                    Multiplayer.send(GameData(query: query), toHost: false)
                }
            }
            
            currentPlayer = playerQueue.nextPlayer(currentPlayer)
            
            if !GameCenter.isOnline {
                // only if host or offline should update time limit
                updateTimeLimit()
            }
            else if GameCenter.isHost{
                updateTimeLimit()
                Multiplayer.send(GameData(timeLimit: timeLimit), toHost: false)
            }
        }
        
        
    
    }
    
    mutating func clearOutput() { output =  "" }
    
    mutating func remove(_ player: Player) {
        if player == currentPlayer {
            // move to next player first if current player is to be removed
            currentPlayer = playerQueue.nextPlayer(currentPlayer)
            timeLeft = timeLimit
        }
        playerQueue.remove(at: playerQueue.firstIndex(of: player)!)
        players.remove(at: players.firstIndex(of: player)!)
    }
    
    mutating func currentPlayerRanOutOfTime() {
        
        
        if GameCenter.isHost {
            Multiplayer.send(GameData(state: .playerTimedOut), toHost: false)
        }
        
        // mark player as no longer in the game
        currentPlayer.livesLeft -= 1
        
        for player in playerQueue {
            print("\(player.name): \(player.livesLeft) lives")
            
        }
        switch currentPlayer.livesLeft == 0 {
        case true:
            output = "\(currentPlayer.name) Lost!"
        case false:
            output = "\(currentPlayer.name) Ran Out of Time!"
        }
        
        currentPlayer = playerQueue.nextPlayer(currentPlayer)
        
        switch playerQueue.count < 2 {
        case true:
            // game over
            handleGameState(.gameOver)
        case false:
            // continue game
            updateTimeLimit()
        }

        
        
        animateExplosion = true
        
    }
    
    mutating func restartGame() {

        timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
        timeLeft = timeLimit
        
        players.reset()
        playerQueue = players
        currentPlayer = playerQueue[0]
        
    }
    mutating func updatePlayerLives(_ updatedPlayers: [String:Int]) {
       
        for player in playerQueue {
            print("before updated \(player.name): \(player.livesLeft) lives")
            if let updatedLives = updatedPlayers[player.name], player.livesLeft != updatedLives {
                player.livesLeft = updatedLives
            }
            print("updated \(player.name): \(player.livesLeft) lives")
        }
    }
    
    mutating func clearUI() {
        output = ""
        query = ""
        instruction = ""
    }
    
    mutating func handleGameState(_ gameState: GameState, data: [String : Any]? = [:]) {
        self.gameState = gameState
        
        switch gameState {
            
        case .initial:
            clearUI()
            
            if let players = data?["players"] as? [Player] {
                self = .init(players)
                
            }
            restartGame()
            
            if let query = data?["query"] as? String {
                self.query = query
            }
            if let instruction = data?["instruction"] as? String {
                self.instruction = instruction
                print("got instruction \(instruction)")
            }
            
            if GameCenter.isHost {
                Multiplayer.send(GameData(model: self), toHost: false)
            }
            
        case .playerInput:
            if let input = data?["input"] as? String, let response = data?["response"] as? (InputStatus, String?) {
                
                process(input, response)
                print("shared model processing input")
                print("\(response)")
            }
            
        case .playerTimedOut:
            timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            currentPlayerRanOutOfTime()
            
        case .gameOver:
            timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            Game.stopTimer()
            
        case .paused:
            break
        case .playing:
            break

        }
    }
}






