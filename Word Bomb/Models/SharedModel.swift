//
//  WordBombGame.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import Foundation
import GameKit
/**
 This is the main model in the MVVM structure of the game. It is the source of truth for everything that is independent of the game mode.
 e.g. it does not implement the function that handles processing of user input since that differs depending on game mode
 */
struct WordBombGame: Codable {
    private enum CodingKeys: String, CodingKey { case players, timeKeeper, media, gameState, output, query, instruction } //this is usually synthesized, but we have to define it ourselves to exclude `game`
    
    var players: Players
    var isMyGKTurn: Bool { GKLocalPlayer.local.displayName == players.current.name }
    
    /// Responsible with processing user inputs and fetching new queries if necessary
    var game: WordGameModel? = nil
    
    var timeKeeper = TimeKeeper()
    var media = Media()
    
    /// The current state of the game
    var gameState: GameState = .initial
    
    /// The number of correct answers used in the game. The score should only be set within the model
//    private(set) var numCorrect = 0
    
    
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
    
    /// inits the appropriate WordGameModel for the given game mode
    /// - Parameter mode: The given game mode
    mutating func setGameModel(with mode: GameMode) {
        let (variants, totalWords) = moc.getWords(db: mode.wordsDB)
        switch mode.gameType {
        case .Exact:
            game = ExactWordGameModel(variants: variants, totalWords: totalWords)
            
        case .Classic:
            game = ContainsWordGameModel(variants: variants,
                                         queries: mode.queriesDB.wordArray.map({ ($0.content, $0.frequency) }),
                                         totalWords: totalWords)
            query = game?.getRandQuery(nil)
        case .Reverse:
            game = ExactWordGameModel(variants: variants, totalWords: totalWords)
        }
        if GameCenter.isHost {
            Multiplayer.send(GameData(variants: variants, totalWords: totalWords), toHost: false)
        }
    }
    
    mutating func setNonHostGameModel(with data: ([String:[String]], Int)) {
        game = ExactWordGameModel(variants: data.0, totalWords: data.1)
    }
    
    /**
     Processes the user's input to determine if it is correct/wrong, and updates the query if necessary
     
     Should be called whenever user commits text in the input textfield
     */
    mutating func processInput(_ input: String) {
       
        let input = input.lowercased().trim()
        print("Processing input: \(input)")
        
        if !(input == "" || timeKeeper.timeLeft <= 0) {
            
            if GameCenter.isHost && isMyGKTurn {
                // turn for device hosting multiplayer game
                
                let response = game!.process(input, query)
                
                handleGameState(.playerInput, data: ["input" : input, "response" : response])
            }
            
            else if GameCenter.isNonHost && isMyGKTurn {
                // turn for device not hosting but in multiplayer game
                Multiplayer.send(GameData(input: input), toHost: true)
                
                print("SENT \(input)")
                
            }
            
            else if !GameCenter.isOnline{
                // device not hosting or participating in multiplayer game i.e offline
                let response = game!.process(input, query)
                
                handleGameState(.playerInput, data: ["input" : input, "response" : response])
            }
        }
    }
    
    /**
     Processes the input received from participating players on the host-side
     
     Should only be called on the host device
     */
    mutating func processNonHostInput(_ input: String) {
        
        print("processing \(input)")
        let response = game!.process(input.lowercased().trim(), query)
        
        handleGameState(.playerInput, data: ["input" : input, "response" : response])
        
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
            game?.updateUsedWords(for: input)
            media.resetROOTSound()
            
            if !GameCenter.isOnline {
                // only if host or offline should update time limit
                timeKeeper.updateTimeLimit()
            }
            else if GameCenter.isHost{
                timeKeeper.updateTimeLimit()
                Multiplayer.send(GameData(timeLimit: timeKeeper.timeLimit), toHost: false)
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
        
        media.resetROOTSound()
        
        // We need to keep game state on non-host devices in sync
        if GameCenter.isHost {
            Multiplayer.send(GameData(state: .playerTimedOut), toHost: false)
        }
        
        let (output, isGameOver) = players.currentPlayerRanOutOfTime()
        self.output = output
        
        if isGameOver {
            handleGameState(.gameOver)
        } else {
            media.playExplosion()
            timeKeeper.updateTimeLimit()
        }
    }
    
    /// Resets the relevant variables to restart the game
    mutating func restartGame() {
        timeKeeper.reset()
        media.reset()
        players.reset()
        game?.reset()
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
            
            restartGame()
            
            if let mode = data?["mode"] as? GameMode {
                setGameModel(with: mode)
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
            timeKeeper.timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            currentPlayerRanOutOfTime()
            
        case .gameOver:
            timeKeeper.timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            Game.stopTimer()
            
        case .paused:
            break
        case .playing:
            break

        }
    }
}






