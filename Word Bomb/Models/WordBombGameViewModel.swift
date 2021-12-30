//
//  CountryWordBombGame.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import Foundation
import GameKit
import GameKitUI
import SwiftUI


/// Main view model that controls most of the game logic
class WordBombGameViewModel: NSObject, ObservableObject {
    
    static func preview(numPlayers: Int = 3) -> WordBombGameViewModel {
        let viewModel = WordBombGameViewModel()
        let players = Players(from: (1...numPlayers).map({"Player \($0)"}))
        
        viewModel.model = WordBombGame(players: players)
        viewModel.gameType = .Classic
        return viewModel
    }
    /// Source of truth for many of the variables that concerns game logic
    @Published var model: WordBombGame = WordBombGame(players: Players())
    
    /// Controls the current view shown to the user
    @Published var viewToShow: ViewToShow = .main {
        willSet {
            if viewToShow == .game && newValue == .main {
                AudioPlayer.playSoundTrack(.BGMusic)
            } else if viewToShow == .waiting && newValue == .game {
                AudioPlayer.playSoundTrack(.GamePlayMusic)
            }
        }
        didSet {
            switch viewToShow {
            case .main:
                gkSelect = false
                trainingMode = false
                gkConnectedPlayers = 0
            default:
                break
            }
        }
    }
    
    /// The game type that the user has currently selected
    @Published var gameType: GameType = .Classic
    
    /// The game mode that the user has currently selected
    @Published var gameMode: GameMode? = nil
    
    /// True if the user has selected the `"GAME CENTER"` option under `"START GAME"`
    @Published var gkSelect = false
    @Published var gkConnectedPlayers = 0
    
    /// True if the user has selected the `"TRAINING MODE"` option under `"START GAME"`
    @Published var trainingMode = false
    
    /// The current user input while in a game
    @Published var input = ""
    
    /// Enables developer-only configurations if True
    @Published var debugging = false
    
    /// Setter for the shared model. Used to sync game state in online games between host and non-hosts
    /// - Parameter model: shared model to be set
    func setSharedModel(_ model: WordBombGame) {
        self.model = model
    }
    
    /// Called when settings menu is dismissed. Resets the shared model to account for any changes.
    func updateGameSettings() {
        model = WordBombGame(players: Players())
    }
    
    /// Resumes the current game
    func resumeGame() {
        viewToShow = .game
        if .gameOver != model.gameState {
            startTimer()
        }
    }
    
    /// Updates the high score of the current mode. Should only be called at gameOver state in training mode
    func updateHighScore() {
        gameMode?.highScore = model.game?.usedWords.count ?? 0 
    }
    
    /// Restarts the game with the same game mode. Only the host of Game Center match or offline play is allowed to call this function.
    func restartGame() {
        model.restartGame()
        viewToShow = .game
        startTimer()
    }

    
    /// Starts a game with the given game mode, not least by initing the appropriate WordGameModel
    /// - Parameter mode: The given game mode
    func startGame(mode: GameMode) {
        withAnimation(Game.mainAnimation) {
            viewToShow = .waiting
        }
        var players = Players()
        gameMode = mode
        
        if trainingMode {
            // Initialise a sharedModel with a single `Player`
            let playerName = (UserDefaults.standard.stringArray(forKey: "Player Names") ?? ["1"]).first!
            players = Players(from:[Player(name: playerName)])
            
        } else if GameCenter.viewModel.showMatch {
            players = getOnlinePlayers(GameCenter.viewModel.gkMatch!.players)
        }
        
        model = WordBombGame(players: players)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            WordBombGame.getGameModel(for: mode) { [self] gameModel in
                model.setGameModel(with: gameModel)
                model.handleGameState(
                    .initial,
                    data: ["instruction":mode.instruction,
                           "query":gameModel.getRandQuery(nil) as Any]
                )
                if !GameCenter.isHost && viewToShow == .waiting {
                    print("starting game")
                    withAnimation(.easeInOut) {
                        viewToShow = .game
                    }
                    startTimer()
                }
            }
        }
    }
    
    /**
     Processes the user's input to determine if it is correct/wrong, and updates the query if necessary
     
     Should be called whenever user commits text in the input textfield
     */
    func processInput() {
        model.processInput(input)
    }
    
    /// Starts the game timer
    func startTimer() {
        print("Timer started")
        
        guard Game.timer == nil else { return }
        Game.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            
            DispatchQueue.main.async {
                if !debugging {
                    model.controller.timeLeft = max(0, model.controller.timeLeft - 0.1)
                }
                
                if GameCenter.isHost {
                    let roundedValue = Int(round(model.controller.timeLeft * 10))
                    
                    if roundedValue % 5 == 0 && model.controller.timeLeft > 0.4 {
                        
                        if GameCenter.isHost {
                            GameCenter.send(GameData(timeLeft: model.controller.timeLeft), toHost: false)
                            
                        }
                        
                    }
                    if roundedValue % 10 == 0 && model.controller.timeLeft > 0.1 {
                        let playerLives = Dictionary(model.players.queue.map { ($0.name, $0.livesLeft) }) { first, _ in first }
                        if GameCenter.isHost {
                            GameCenter.send(GameData(playerLives: playerLives), toHost: false)
                            
                        }
                    }
                }
            }

            if model.controller.timeLeft < 3 {
                // do not interrupt if explosion sound is playing
                AudioPlayer.playROOTSound()
            }
            
            if model.controller.timeLeft <= 0 && (GameCenter.isHost || !GameCenter.isOnline) {
                // only handle time out if host of online match or in offline play 
                
                DispatchQueue.main.async {
                    self.model.handleGameState(.playerTimedOut)
                }
            }
        }
    }
    
    /// Handles the given game state by passing it on to the model (source of truth)
    /// - Parameters:
    ///   - gameState: The game state to be handled
    ///   - data: Key-value mapping of any relevant data for the handling
    func handleGameState(_ gameState: GameState, data: [String : Any]? = [:]) {
        model.handleGameState(gameState, data: data)
    }
    
}

// MARK: - MULTIPLAYER SECTION
extension WordBombGameViewModel {
    
    /// True if it is the current device's turn in a Game Center match
    var isMyGKTurn: Bool { GKLocalPlayer.local.displayName == model.players.current.name }
    
    /**
     Resets the model (source of truth)
     
     Should be called when a multiplayer game has ended either due to lack of players, lost of connection or the game has ended
     */
    func resetGameModel() {
        model = .init(players: Players())
        Game.stopTimer()
    }
    
    /// Removes the disconnected player from the game
    func handleDisconnected(from playerName: String) {
        let playerQueue = model.players.queue
        for i in playerQueue.indices {
            guard i < playerQueue.count else { return }
            // if multiple disconnects at the same time -> this function may be called simultaneously
            if playerName == playerQueue[i].name {
                model.remove(playerQueue[i])
            }
            // function does not do anything if player is not in queue (e.g. the player lost just before disconnecting)
        }
    }
   
    /// Returns `Players` object for those participating in the Game Center match
    /// - Parameter gkPlayers: Array of GKPlayer objects participating in the match
    func getOnlinePlayers(_ gkPlayers: [GKPlayer]) -> Players {
        
        var players: [Player] = [Player(name: GKLocalPlayer.local.displayName)]
        
        for player in gkPlayers {
            players.append(Player(name: player.displayName))
        }
        setGKPlayerImages(for: players, with: gkPlayers)
        return Players(from: players)
    }
    
    /// Updates `Player` objects with their corresponding Game Center profile picture
    /// - Parameter players: Array of `Player` objects to be updated
    /// - Parameter gkPlayers: Array of GKPlayer objects participating in the match
    func setGKPlayerImages(for players: [Player], with gkPlayers: [GKPlayer]) {
        for player in players {
            if player.name == GKLocalPlayer.local.displayName {
                GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.normal) { image, error in
                    print("got image for player \(player.name) with error \(String(describing: error))")
                    player.setImage(image)
                }
            }
            else {
                for gkPlayer in gkPlayers {
                    if player.name == gkPlayer.displayName {
                        gkPlayer.loadPhoto(for: GKPlayer.PhotoSize.normal) { image, error in
                            print("got image for player \(player.name) with error \(String(describing: error))")
                            player.setImage(image)
                        }
                    }
                }
            }
        }
    }
}
