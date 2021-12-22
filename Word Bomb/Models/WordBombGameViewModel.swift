//
//  CountryWordBombGame.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import Foundation
import GameKit
import GameKitUI


class WordBombGameViewModel: NSObject, ObservableObject {
    
    @Published private var model: WordBombGame = WordBombGame()
    @Published private var gameModel: WordGameModel? = nil
    @Published var viewToShow: ViewToShow = .main {
        didSet {
            switch viewToShow {
            case .main:
                gkSelect = false
            case .game:
                forceHideKeyboard = false
            default:
                forceHideKeyboard = true
            }
        }
    }
    @Published var gameMode: GameMode? = nil
    
    @Published var gkSelect = false
    
    @Published var input = ""
    @Published var forceHideKeyboard = false
    @Published var gameType: GameType = .Classic
    
    @Published var debugging = false
    
    init(_ viewToShow: ViewToShow = .main) {
        self.viewToShow = viewToShow
        
    }
    
    func setSharedModel(_ model: WordBombGame) {
        self.model = model
        self.model.currentPlayer = self.model.playerQueue[0]
    }
    func updatePlayerLives(_ updatedPlayers: [String:Int]) {
        model.updatePlayerLives(updatedPlayers)
    }
    func updateGameSettings() {
        model = WordBombGame()
    }
    
    func pauseGame() {
        viewToShow = .pauseMenu
        Game.playSound(file: "back")
        Game.stopTimer()
    }
    
    func resumeGame() {
        viewToShow = .game
        if .gameOver != gameState {
            startTimer()
        }
    }
    
    func restartGame() {
        
        guard var gameModel = gameModel else {
            print("mode not found")
            return
        }
        
        gameModel.reset()
        
        if GameCenter.isHost {
            setOnlinePlayers(GameCenter.viewModel.gkMatch!.players)
        }
        startGame(mode: gameMode!)
        
    }
    
    func startGame(mode: GameMode) {
        
        // process the gameMode by initing the appropriate WordGameModel
        gameMode = mode
        
        switch mode.gameType {
        case .Exact: gameModel = ExactWordGameModel(wordsDB: mode.wordsDB)
            
        case .Classic:
            let queries = mode.queriesDB.words.map({ ($0.content, $0.frequency) })
            gameModel = ContainsWordGameModel(wordsDB: mode.wordsDB, queries: queries)
            
        case .Reverse:
            gameModel = ReverseWordGameModel(wordsDB: mode.wordsDB)
        }
        
        if GameCenter.isHost || !GameCenter.isOnline {
            print("getting query")
            // should query only if device is hosting a game or not in multiplayer game
            model.handleGameState(.initial,
                                  data: ["query" : gameModel!.getRandQuery(nil),
                                         "instruction" : mode.instruction])
        }
        else { model.handleGameState(.initial,
                                     data: ["instruction" : mode.instruction]) }
        viewToShow = .game
        startTimer()
    }
    
    func processInput() {
        
        
        input = input.lowercased().trim()
        
        if !(input == "" || model.timeLeft <= 0) {
            
            if GameCenter.isHost && isMyGKTurn {
                // turn for device hosting multiplayer game
                
                let response = gameModel!.process(input, model.query)
                
                model.handleGameState(.playerInput, data: ["input" : input, "response" : response])
            }
            
            else if GameCenter.isNonHost && isMyGKTurn {
                // turn for device not hosting but in multiplayer game
                Multiplayer.send(GameData(input: input), toHost: true)
                
                print("SENT \(input)")
                
            }
            
            else if !GameCenter.isOnline{
                // device not hosting or participating in multiplayer game i.e offline
                let response = gameModel!.process(input, model.query)
                
                model.handleGameState(.playerInput, data: ["input" : input, "response" : response])
            }
        }
    }
    
    func startTimer() {
        print("Timer started")
        
        guard Game.timer == nil else { return }
        Game.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            
            
            DispatchQueue.main.async {
                if !debugging {
                    model.timeLeft = max(0, model.timeLeft - 0.1)
                }
                
                if GameCenter.isHost {
                    let roundedValue = Int(round(model.timeLeft * 10))
                    
                    if roundedValue % 5 == 0 && model.timeLeft > 0.4 {
                        
                        if GameCenter.isHost {
                            Multiplayer.send(GameData(timeLeft: timeLeft), toHost: false)
                            
                        }
                        
                    }
                    if roundedValue % 10 == 0 && model.timeLeft > 0.1 {
                        let playerLives = Dictionary(model.playerQueue.map { ($0.name, $0.livesLeft) }) { first, _ in first }
                        if GameCenter.isHost {
                            Multiplayer.send(GameData(playerLives: playerLives), toHost: false)
                            
                        }
                        
                    }
                }
            }
            
            if model.timeLeft <= 0 && (GameCenter.isHost || !GameCenter.isOnline) {
                // only handle time out if host of online match or in offline play 
                
                DispatchQueue.main.async {
                    self.model.handleGameState(.playerTimedOut)
                }
            }
        }
    }
    
    func handleGameState(_ gameState: GameState, data: [String : Any]? = [:]) {
        model.handleGameState(gameState, data: data)
    }
    
    // check if output is still the same as current to avoid clearing of new outputs
    func clearOutput(_ output: String) { if output == model.output { model.clearOutput() } }
    
    // to allow contentView to read model's value and update
    var playerQueue: [Player] { model.playerQueue }
    
    var currentPlayer: Player { model.currentPlayer }
    
    var livesLeft: Int { model.livesLeft }
    
    var instruction: String? { model.instruction }
    
    var query: String? {
        get { model.query }
        set { model.query = newValue }
    }
    
    var timeLimit: Float {
        get { model.timeLimit }
        set { model.timeLimit = newValue }
    }
    
    var timeLeft: Float {
        get { model.timeLeft }
        set { model.timeLeft = newValue }
    }
    
    var output: String { model.output }
    
    var gameState: GameState { model.gameState }
    
    var animateExplosion: Bool {
        
        get { model.animateExplosion }
        set { model.animateExplosion =  newValue }
    }
    
    
}

// MARK: - MULTIPLAYER
extension WordBombGameViewModel {
    
    var isMyGKTurn: Bool { GKLocalPlayer.local.displayName == model.currentPlayer.name }
    var isMyTurn: Bool { UserDefaults.standard.string(forKey: "Display Name")! == model.currentPlayer.name }
    
    func resetGameModel() {
        // called when a multiplayer game has ended either due to lack of players, lost of connection or game just ended
        model = .init()
        Game.stopTimer()
    }
    
    func handleDisconnected(from playerName: String) {
        for i in playerQueue.indices {
            guard i < playerQueue.count else { return }
            // if multiple disconnects at the same time -> this function may be called simultaneously
            if playerName == playerQueue[i].name {
                model.remove(playerQueue[i])
            }
            // function does not do anything if player is not in queue (e.g. the player lost just before disconnecting)
        }
    }
    func processNonHostInput(_ input: String) {
        
        print("processing \(input)")
        let response = gameModel!.process(input.lowercased().trim(), model.query)
        
        model.handleGameState(.playerInput, data: ["input" : input, "response" : response])
        
    }
    
    func setOnlinePlayers(_ players: [Any])  {
        guard let gkPlayers = players as? [GKPlayer] else { fatalError("Not a valid array of players") }
        
        var players: [Player] = [Player(name: GKLocalPlayer.local.displayName)]
        
        for player in gkPlayers {
            players.append(Player(name: player.displayName))
        }
        model = .init(players)
        print("gkplayers \(model.playerQueue)")
        print("current player \(model.currentPlayer)")
        setGKPlayerImages(gkPlayers)
        
    }
}

// MARK: - GAME CENTER
extension WordBombGameViewModel {
    func setGKPlayerImages(_ gkPlayers: [GKPlayer]) {
        for player in model.playerQueue {
            if player.name == GKLocalPlayer.local.displayName {
                GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.normal) { image, error in
                    print("got image \(image ?? nil) for player \(player.name) with error \(String(describing: error))")
                    player.setImage(image)
                }
            }
            else {
                for gkPlayer in gkPlayers {
                    if player.name == gkPlayer.displayName {
                        gkPlayer.loadPhoto(for: GKPlayer.PhotoSize.normal) { image, error in
                            print("got image \(image ?? nil) for player \(player.name) with error \(String(describing: error))")
                            player.setImage(image)
                        }
                    }
                }
            }
        }
    }
}

