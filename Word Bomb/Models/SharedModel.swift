//
//  WordBombGame.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import Foundation

/**
 This is the main model in the MVVM structure of the game. It is the source of truth for everything that is independent of the game mode.
 e.g. it does not implement the function that handles processing of user input since that differs depending on game mode
 */
struct WordBombGame: Codable {
    /**
     A mutating array of `Player` objects that provides information about the current sequence of players.
     
     The order of objects in `playerQueue` is modified after each turn; it follows a carousel-like structure.
     `Player` objects are removed from `playerQueue` when they run out of lives
     */
    var playerQueue: [Player]
    
    /// Non-mutating array of `Player` objects containing every player in the current game. This allows us to reset `playerQueue` when restarting the game .
    var players: [Player]
    
    /// The `Player` object representing the current player in the game
    var currentPlayer: Player
    
    /// The number of lives that each player begins with, as per the host's settings
    var livesLeft = UserDefaults.standard.integer(forKey: "Player Lives")
    
    /// The time allowed for each player, as per the host's settings. The limit may decrease with each turn depending on the other relevant settings
    var timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// The amount of time left for the current player.
    var timeLeft = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// The current state of the game
    var gameState: GameState = .initial
    
    /// The output text to be displayed depending on player input
    var output = ""
    
    /// The query text to be displayed
    var query: String?
    
    /// The instruction text to be displayed
    var instruction = "" {
        didSet {
            print("instruction set to \(instruction)")
        }
    }
    /// Controls when the explosion animation is run. Should be true when a player runs out of time
    var animateExplosion = false
    
    /// Controls the playback of the sound when `timeLeft` is low.
    var playRunningOutOfTimeSound = false
    
    /// Initialises the shared model with an optional array of `Player` objects
    /// - Parameter players: if `players` is nil, fallback to the user settings for the number of players and the names of each player
    init(_ players: [Player]? = nil) {
        if let players = players {
            self.playerQueue = players
            
        }
        else {
            self.playerQueue = []
            let playerNames = UserDefaults.standard.stringArray(forKey: "Player Names") ?? []

            for i in 0..<max(1, UserDefaults.standard.integer(forKey: "Num Players")) {
                
                if i >= playerNames.count {
                    // If no name was set by the user for this player, create one with a generic name
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
    
    /// Updates the time limit based on the the `"Time Multiplier"` and `"Time Constraint"` settings
    mutating func updateTimeLimit() {
        if currentPlayer == players.first! {
            timeLimit = max(UserDefaults.standard.float(forKey:"Time Constraint"), timeLimit * UserDefaults.standard.float(forKey: "Time Multiplier"))
            print("time multiplied")
        }
        timeLeft = timeLimit
    }
    
    /// Updates the time left & time limit and output & query texts depending on the outcome of the user input.
    /// - Parameters:
    ///   - input: The user's input
    ///   - response: The outcome of the user input. Contains a new query depending on the outcome.
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
    
    /// Resets the output text to an empty string
    mutating func clearOutput() { output =  "" }
    
    /// Removes `player` from the game. Should be called in multiplayer context if `player` disconnects
    /// - Parameter player: `Player` object to be removed
    mutating func remove(_ player: Player) {
        if player == currentPlayer {
            // move to next player first if current player is to be removed
            currentPlayer = playerQueue.nextPlayer(currentPlayer)
            timeLeft = timeLimit
        }
        playerQueue.remove(at: playerQueue.firstIndex(of: player)!)
        players.remove(at: players.firstIndex(of: player)!)
    }
    
    /// Handles the game state when the current player runs out of time
    mutating func currentPlayerRanOutOfTime() {
        
        Game.playSound(file: "explosion")
        playRunningOutOfTimeSound = false
        animateExplosion = true
        
        // We need to keep game state on non-host devices in sync
        if GameCenter.isHost {
            Multiplayer.send(GameData(state: .playerTimedOut), toHost: false)
        }

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

        guard playerQueue.count != 1 else {
            // User is playing in training mode
            return currentPlayer.livesLeft == 0 ? handleGameState(.gameOver) : updateTimeLimit()
        }
        
        currentPlayer = playerQueue.nextPlayer(currentPlayer)
        
        switch playerQueue.count < 2 {
        case true:
            handleGameState(.gameOver)
        case false:
            updateTimeLimit()
        }
        
    }
    
    /// Resets the relevant variables to restart the game
    mutating func restartGame() {

        timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
        timeLeft = timeLimit
        
        players.reset()
        playerQueue = players
        currentPlayer = playerQueue[0]
        
    }
    
    /// Sets the relevant `Player` objects with the given `livesleft`.  Called in a multiplayer context to sync game state on non-host devices.
    /// - Parameter updatedPlayers: Mapping from `Player` name to lives left
    mutating func updatePlayerLives(_ updatedPlayers: [String:Int]) {
       
        for player in playerQueue {
            print("before updated \(player.name): \(player.livesLeft) lives")
            if let updatedLives = updatedPlayers[player.name], player.livesLeft != updatedLives {
                player.livesLeft = updatedLives
            }
            print("updated \(player.name): \(player.livesLeft) lives")
        }
    }
    
    /// Resets the output, query and instruction texts to empty strings
    mutating func clearUI() {
        output = ""
        query = ""
        instruction = ""
    }
    
    /// Updates relevant variables depending on the given game state and the data provided
    /// - Parameters:
    ///   - gameState: The given game state
    ///   - data: Key-value mapping for any relevant data to be used by the handler
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






