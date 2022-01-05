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
    private enum CodingKeys: String, CodingKey { case players, controller, settings, output, query, instruction }
    // this is usually synthesized, but we have to define it ourselves to exclude various properties
    // `game` is not codable, the others are not needed to sync gameState at initialisation
    
    var players: Players
    
    var isMyGKTurn: Bool { GKLocalPlayer.local.displayName == players.current.name }
    
    /// Responsible with processing user inputs and fetching new queries if necessary
    var game: WordGameModel? = nil
    
    var controller: Controller
    
    /// The current state of the game
    var gameState: GameState = .Initial
    
    /// The current correct answers used in the game. Should only be set within the model
    var numCorrect = 0
    
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
    
    var settings: Game.Settings
    
    init(players: Players, settings: Game.Settings) {
        self.settings = settings
        self.players = players
        self.players.useSettings(settings)
        self.controller = Controller(settings: settings)
    }
    
    /// Returns the appropriate WordGameModel for the given game mode
    /// - Parameter mode: The given game mode
    static func getGameModel(for mode: GameMode, completion: @escaping (WordGameModel) -> Void) {
        PersistenceController.shared.container.performBackgroundTask { moc in
            
            let (variants, totalWords) = moc.getWords(db: mode.wordsDB)
            var model: WordGameModel
            
            switch mode.gameType {
            case .Exact:
                model = ExactWordGameModel(variants: variants, totalWords: totalWords)
                
            case .Classic:
                model = ContainsWordGameModel(variants: variants,
                                             queries: mode.queriesDB.wordArray.map({ ($0.content, $0.frequency) }),
                                             totalWords: totalWords)
            case .Reverse:
                model = ReverseWordGameModel(variants: variants, totalWords: totalWords)
            }
            if GameCenter.isHost {
                if mode.wordsDB.name == "words" {
                    GameCenter.send(GameData(variants: [:], totalWords: -1), toHost: false)
                } else {
                    GameCenter.send(GameData(variants: variants, totalWords: totalWords), toHost: false)
                }
            }
            DispatchQueue.main.async {
                completion(model)
            }
        }
    }
    
    static func getNonHostGameModel(_ variants: [String:[String]], totalWords: Int, completion: @escaping (WordGameModel) -> Void) {
        PersistenceController.shared.container.performBackgroundTask() { moc in
            
            var model: WordGameModel
            
            if totalWords == -1 {
                let request = Database.fetchRequest()
                request.predicate = NSPredicate(format: "name_ = %@", "words")
                request.fetchLimit = 1
                let db = moc.safeFetch(request).first!
                let (variants, totalWords) = moc.getWords(db: db)
                model = ContainsWordGameModel(variants: variants, queries: [], totalWords: totalWords)
            } else {
                model = ContainsWordGameModel(variants: variants, queries: [], totalWords: totalWords)
            }
            
            DispatchQueue.main.async {
                completion(model)
            }
        }
    }
    mutating func setGameModel(with model: WordGameModel) {
        game = model
    }
    
    /**
     Processes the user's input to determine if it is correct/wrong, and updates the query if necessary
     
     Should be called whenever user commits text in the input textfield
     */
    mutating func processInput(_ input: String) {
       
        let input = input.lowercased().trim()
        print("Processing input: \(input)")
        
        if !(input == "" || controller.timeLeft <= 0) {
            if GameCenter.isHost && isMyGKTurn {
                // turn for device hosting multiplayer game
                let response = game!.process(input, query)
                handleGameState(.PlayerInput, data: ["input" : input, "response" : response])
            }
            
            else if GameCenter.isNonHost && isMyGKTurn {
                // turn for device not hosting but in multiplayer game
                GameCenter.send(GameData(input: input), toHost: true)
                print("SENT \(input)")
            }
            
            else if !GameCenter.isOnline{
                // device not hosting or participating in multiplayer game i.e offline
                let response = game!.process(input, query)
                handleGameState(.PlayerInput, data: ["input" : input, "response" : response])
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
        
        handleGameState(.PlayerInput, data: ["input" : input, "response" : response])
    }
    
    /// Updates the time left & time limit and output & query texts depending on the outcome of the user input.
    /// - Parameters:
    ///   - input: The user's input
    ///   - response: The `Response` object representing the outcome of `input`
    mutating func process(_ response: Response) {
        print("handling player input")
        // reset the time for other player iff answer from prev player was correct
        
        if GameCenter.isHost {
            GameCenter.send(GameData(state: .PlayerInput,
                                     response: response),
                            toHost: false)
        }
        
        output = response.output
        
        players.handleInput(response)
        
        if response.status == .Correct {

            if let newQuery = response.newQuery {
                self.query = newQuery
            }
            
            numCorrect += 1
            game?.updateUsedWords(for: response.input)
            
            if !GameCenter.isOnline {
                // only if host or offline should update time limit
                controller.updateTimeLimit()
            }
            else if GameCenter.isHost{
                controller.updateTimeLimit()
                GameCenter.send(GameData(timeLimit: controller.timeLimit), toHost: false)
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
        
        // We need to keep game state on non-host devices in sync
        if GameCenter.isHost {
            GameCenter.send(GameData(state: .PlayerTimedOut), toHost: false)
        }
        
        let (output, isGameOver) = players.currentPlayerRanOutOfTime()
        self.output = output
        
        
        if isGameOver {
            if !players.getWinningPlayer() {
                handleGameState(.GameOver)
            } else {
                handleGameState(.TieBreak)
                controller.updateTimeLimit()
                Game.stopTimer() // wait for user to ready up
            }
        } else {
            controller.playExplosion()
            controller.updateTimeLimit()
        }
    }
    
    /// Resets the relevant variables to restart the game
    mutating func restartGame() {
        numCorrect = 0
        
        controller.reset()
        players.reset()
        game?.reset()
        
        query = game?.getRandQuery(nil)
        handleGameState(.Initial)
        GameCenter.send(GameData(state: .Initial), toHost: false)
    }
    
    /// Updates relevant variables depending on the given game state and the data provided
    /// - Parameters:
    ///   - gameState: The given game state
    ///   - data: Key-value mapping for any relevant data to be used by the handler
    mutating func handleGameState(_ gameState: GameState, data: [String : Any]? = [:]) {
        self.gameState = gameState
        
        switch gameState {
            
        case .Initial:
            if let instruction = data?["instruction"] as? String {
                self.instruction = instruction
            }
            if let query = data?["query"] as? String {
                self.query = query
            }
            
            if GameCenter.isHost {
                GameCenter.send(GameData(model: self), toHost: false)
            }
            
        case .PlayerInput:
            if let response = data?["response"] as? Response {
                process(response)
                print("shared model processing input with response: \(response)")
                
            }
        
        case .PlayerTimedOut:
            controller.timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            currentPlayerRanOutOfTime()
            
        case .GameOver:
            controller.timeLeft = 0.0 // for multiplayer games if non-host is lagging behind in their timer
            Game.stopTimer()
            if GameCenter.isHost {
                GameCenter.send(GameData(state: .GameOver), toHost: false)
            }
        case .TieBreak:
            if !GameCenter.isNonHost {
                query = game?.getRandQuery(nil) // get new query for when game restarts
                GameCenter.send(GameData(state: .TieBreak, query: query), toHost: false)
            }
        case .Playing:
            if GameCenter.isHost {
                GameCenter.send(GameData(state: .Playing), toHost: false)
            }
        }
    }
}






