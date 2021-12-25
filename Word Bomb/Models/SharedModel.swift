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
    
    var players: Players
    
    /// The number of lives that each player begins with, as per the host's settings
    
    /// The time allowed for each player, as per the host's settings. The limit may decrease with each turn depending on the other relevant settings
    private(set) var timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// The amount of time left for the current player.
    var timeLeft = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// The current state of the game
    var gameState: GameState = .initial
    
    /// The number of correct answers used in the game. The score should only be set within the model
    private(set) var numCorrect = 0
    
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
    
    /// Controls the playback of the sound when `timeLeft` is low. Should be set to false after each turn.
    var playRunningOutOfTimeSound = false
    
    /// Updates the time limit based on the the `"Time Multiplier"` and `"Time Constraint"` settings
    mutating func updateTimeLimit() {
        // TODO: why do we need this conditional
        if players.current == players.queue.first! {
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
            _ = players.nextPlayer()
            numCorrect += 1
            playRunningOutOfTimeSound = false
            
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
    
    /// Removes `player` from the game. Should be called in multiplayer context if `player` disconnects
    /// - Parameter player: `Player` object to be removed
    mutating func remove(_ player: Player) {
        players.remove(player)
    }
    
    /// Handles the game state when the current player runs out of time
    mutating func currentPlayerRanOutOfTime() {
        
        playRunningOutOfTimeSound = false
        
        // We need to keep game state on non-host devices in sync
        if GameCenter.isHost {
            Multiplayer.send(GameData(state: .playerTimedOut), toHost: false)
        }
        
        let (output, isGameOver) = players.currentPlayerRanOutOfTime()
        self.output = output
        
        if isGameOver {
            handleGameState(.gameOver)
        } else {
            animateExplosion = true
            Game.playSound(file: "explosion")
            updateTimeLimit()
        }
    }
    
    /// Resets the relevant variables to restart the game
    mutating func restartGame() {

        timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
        timeLeft = timeLimit
        players.reset()
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
                self.players = Players(from: players)
                
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






