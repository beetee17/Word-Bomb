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
        
        let players = Players(from: (1...numPlayers).map({"\($0)"}))
        let model = WordBombGame(players: players, settings: Game.Settings(), preview: true)
        let viewModel = WordBombGameViewModel(model: model)
        return viewModel
    }
    
    init(model: WordBombGame = WordBombGame(players: Players(), settings: Game.Settings())) {
        self.model = model
    }
    /// Source of truth for many of the variables that concerns game logic
    @Published var model: WordBombGame
    
    /// Controls the current view shown to the user
    @Published var viewToShow: ViewToShow = .Main {
        willSet {
            if viewToShow == .Game && newValue == .Main {
                AudioPlayer.playSoundTrack(.BGMusic)
                AudioPlayer.shared?.pause()
            } else if viewToShow == .Waiting && newValue == .Game {
                AudioPlayer.playSoundTrack(.GamePlayMusic)
            }
        }
        didSet {
            switch viewToShow {
            case .Main:
                gkSelect = false
                arcadeMode = false
                frenzyMode = false
                gkConnectedPlayers = 0
                Game.stopTimer()
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
    
    /// True if the user has selected the `"ARCADE"` option under `"START GAME"`
    @Published var arcadeMode = false
    
    /// True if the user has selected the `"FRENZY"` option under `"START GAME"`
    @Published var frenzyMode = false
    
    /// The current user input while in a game
    @Published var input = ""
    
    /// Enables developer-only configurations if True
    @Published var debugging = false
    
    /// Setter for the shared model. Used to sync game state in online games between host and non-hosts
    /// - Parameter model: shared model to be set
    func setSharedModel(_ model: WordBombGame) {
        self.model = model
        self.model.players.updateCurrentPlayer()
    }
    
    /// Called when settings menu is dismissed. Resets the shared model to account for any changes.
    func updateGameSettings() {
        model.setSettings(with: Game.Settings())
    }
    
    /// Resumes the current game
    func resumeGame() {
        viewToShow = .Game
        if .GameOver != model.gameState {
            startTimer()
        }
    }
    
    /// Restarts the game with the same game mode. Only the host of Game Center match or offline play is allowed to call this function.
    func restartGame() {
        gkConnectedPlayers = 0
        model.restartGame()
        startGame()
    }

    func getSinglePlayer() -> Player {
        var player: Player
        if GKLocalPlayer.local.isAuthenticated {
            player = Player(name: GKLocalPlayer.local.displayName, queueNumber: 0)
            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.normal) { image, error in
                print("got image for player \(player.name) with error \(String(describing: error))")
                player.setImage(image)
            }
        } else {
            let playerName = (UserDefaults.standard.stringArray(forKey: "Player Names") ?? ["1"]).first!
            player = Player(name: playerName, queueNumber: 0)
        }
        return player
    }
    
    /// Starts a game with the given game mode, not least by initing the appropriate WordGameModel
    /// - Parameter mode: The given game mode
    func startGame() {
        withAnimation(Game.mainAnimation) {
            viewToShow = .Waiting
        }
        model.restartGame()
        GameCenter.send(GameData(state: .Initial), toHost: false)
        
        let request = GameMode.fetchRequest()
        request.predicate = NSPredicate(format: "name_ = %@ AND gameType_ = %@", "words", GameType.Classic.rawValue)
        request.fetchLimit = 1
        self.gameMode = moc.safeFetch(request).first!
            
        var players = Players()
       
        if arcadeMode {
            // Initialise a sharedModel with a single `Player` object
            let player = getSinglePlayer()
            
            let settings = Game.Settings(timeLimit: 15,
                                         timeConstraint: 8,
                                         timeMultiplier: 0.98,
                                         playerLives: 3,
                                         numTurnsBeforeNewQuery: 1)
            model.setPlayers(with: Players(from: [player]))
            model.setSettings(with: settings)
            
        } else if GameCenter.viewModel.showMatch && GameCenter.isHost {
            // Always use the host settings
            players = getOnlinePlayers(GameCenter.viewModel.gkMatch!.players)
            model.setPlayers(with: players)
            model.setSettings(with: Game.Settings())
        } else if frenzyMode {
            // Initialise a sharedModel with a single `Player` object
            let player = getSinglePlayer()
            
            let settings = Game.Settings(timeLimit: 90,
                                         timeConstraint: 0,
                                         timeMultiplier: nil,
                                         playerLives: 1,
                                         numTurnsBeforeNewQuery: 1)
            model.setPlayers(with: Players(from: [player]))
            model.setSettings(with: settings)
        } else {
            // user playing pass and play offline mode
            model.setPlayers(with: Players())
            model.setSettings(with: Game.Settings())
        }

        DispatchQueue.main.asyncAfter(deadline:.now() + 0.75) { [self] in
            model.handleGameState(.Initial)
            if !GameCenter.isHost && viewToShow == .Waiting {
                print("starting game")
                withAnimation(.easeInOut) {
                    viewToShow = .Game
                }
                startTimer()
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
                }
            }
                
            if model.controller.timeLeft <= 0 && (GameCenter.isHost || !GameCenter.isOnline) {
                // only handle time out if host of online match or in offline play 
                
                DispatchQueue.main.async {
                    self.model.handleGameState(.PlayerTimedOut)
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
                      
    func claimReward(of type: RewardType) {
        model.claimReward(of: type)
    }
    
    func passQuery() {
        model.controller.addTime(-5)
        model.query = model.game.getRandQuery(nil)
        AudioPlayer.playSound(.Wrong)
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
        model.setPlayers(with: Players())
        model.setSettings(with: Game.Settings())
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
    /// Only the host player should require this function
    func getOnlinePlayers(_ gkPlayers: [GKPlayer]) -> Players {
        
        var players: [Player] = [Player(name: GKLocalPlayer.local.displayName,
                                        queueNumber: 0)]
        
        for i in gkPlayers.indices {
            players.append(Player(name: gkPlayers[i].displayName,
                                  queueNumber: i+1))
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
