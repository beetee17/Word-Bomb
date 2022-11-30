//
//  GamePlayView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 14/7/21.
//

import SwiftUI
import GameKit
import GameKitUI

struct GamePlayView: View, Equatable {
    static func == (lhs: GamePlayView, rhs: GamePlayView) -> Bool {
        lhs.props == rhs.props &&
        lhs.input == rhs.input &&
        lhs.output == rhs.output &&
        lhs.gkMatch == rhs.gkMatch
    }
    
    var viewModel: WordBombGameViewModel = Game.viewModel
    
    var props: Props
    
    @ObservedObject var IAPHandler = UserViewModel.shared
    
    @Binding var input: String
    @Binding var output: String
    
    @State var showMatchProgress = false
    @State var showUsedLetters = false
    @State var gamePaused = false
    @State var forceHideKeyboard = false
    
    var gkMatch: GKMatch?
    
    var body: some View {
        print("Redrawing GamePlayView")
        return ZStack {
            VStack {
                if !IAPHandler.subscriptionActive {
                    BannerAd(adID: .Test)
                        .frame(width: 320, height: 50)
                } else {
                    Color.clear.frame(width: 320, height: 50)
                }
                
                ZStack {
                    Color.clear
                    
                    VStack(spacing:0) {
                        
                        TopBarView(gamePaused: $gamePaused,
                                   showMatchProgress: $showMatchProgress,
                                   showUsedLetters: $showUsedLetters,
                                   gkMatch: gkMatch)
                        .zIndex(1)
                        
                        PlayerView(props: props.playerViewProps)
                            .offset(y: -Device.height*0.05)
                        
                        
                        Spacer()
                    }
                }
            }

            GamePlayArea(props: props.gamePlayAreaProps,
                         input: $input,
                         output: $output,
                         forceHideKeyboard: $forceHideKeyboard)
            .equatable()
            .ignoresSafeArea(.all)
        }
    
        .blur(radius: gamePaused || showMatchProgress || showUsedLetters ? 10 : 0, opaque: false)
        .overlay(
            MatchProgressView(usedWords: props.usedWords, showMatchProgress: $showMatchProgress)
        )
        .overlay(PauseMenuView(gamePaused: $gamePaused))
        .overlay(AlphabetTracker(usedLetters: props.usedLetters, isShowing: $showUsedLetters))
        .onChange(of: gamePaused) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showMatchProgress) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showUsedLetters) { newValue in
            forceHideKeyboard = newValue
        }
        .if(props.gamePlayAreaProps.gameState == .TieBreak && !GameCenter.isNonHost) {
            // Do not allow non host to resume the tie breaker
            $0.onTapGesture {
                viewModel.startTimer()
                viewModel.model.handleGameState(.Playing)
            }
        }
    }
}

extension GamePlayView {
    struct Props: Equatable {
        var gamePlayAreaProps: GamePlayArea.Props
        var playerViewProps: PlayerView.Props
        
        var usedLetters: Set<String>
        var usedWords: [String]
    }
}

extension WordBombGameViewModel {
    var gamePlayViewProps: GamePlayView.Props {
        .init(gamePlayAreaProps: gamePlayAreaProps,
              playerViewProps: playerViewProps,
              usedLetters: model.players.current.usedLetters,
              usedWords: model.game.usedWords.sorted())
    }
}


struct GamePlayArea: View, Equatable {
    static func == (lhs: GamePlayArea, rhs: GamePlayArea) -> Bool {
        lhs.props == rhs.props &&
        lhs.input == rhs.input &&
        lhs.output == rhs.output &&
        lhs.forceHideKeyboard == rhs.forceHideKeyboard
    }
    
    var viewModel: WordBombGameViewModel = Game.viewModel
    
    var props: Props
    
    @Binding var input: String
    @Binding var output: String
    @Binding var forceHideKeyboard: Bool
    
    var body: some View {
        print("Redrawing GamePlayArea")
        return VStack(spacing:0) {
            Spacer()
            switch props.gameState {
            case .GameOver:
                let arcadeHighScore = props.gameMode?.arcadeHighScore
                let frenzyHighScore = props.gameMode?.frenzyHighScore

                GameOverText(prevBest: (props.arcadeMode ? arcadeHighScore : frenzyHighScore) ?? -1)
            case .TieBreak:
                Text("TIED!").boldText()
                Text("Tap to Continue").boldText()
            default:
                if props.frenzyMode {
                    Game.MainButton(label: "PASS", systemImageName: "questionmark.square.fill") {
                        viewModel.passQuery()
                    }
                }
                
                Text(props.instruction)
                    .font(.headline)
                    .bold()
                    .textCase(.uppercase)
                
                let queryText = Array(props.query ?? "")
                let highlightIndex =  getQueryHighlightIndex()
                
                HStack(spacing: 0) {
                    ForEach(Array(queryText.enumerated()), id:\.0) { index, char in
                        Text(String(char))
                            .boldText()
                            .foregroundColor(index < highlightIndex ? .green : .white)
                    }
                }
            
                
                PermanentKeyboard(
                    text: $input,
                    forceResignFirstResponder: $forceHideKeyboard
                ) {
                    viewModel.processInput()
                }
                .font(Font.system(size: 20))
            }
            
            OutputText(text: $output)
            Spacer()
        }
    }
    
    private func getQueryHighlightIndex() -> Int {
        let input = input.lowercased()
        let query = props.query?.lowercased() ?? ""
        
        var count = -1
        
        for i in (0...query.count) {
            if input.contains(query.prefix(i)) {
                count = i
            }
        }
        return count
    }
}

extension GamePlayArea {
    struct Props: Equatable {
        var gameState: GameState
        var gameMode: GameMode?
        var frenzyMode: Bool
        var arcadeMode: Bool
        var instruction: String
        var query: String?
    }
}

extension WordBombGameViewModel {
    var gamePlayAreaProps: GamePlayArea.Props {
        .init(gameState: model.gameState,
              gameMode: gameMode,
              frenzyMode: frenzyMode,
              arcadeMode: arcadeMode,
              instruction: model.instruction,
              query: model.query)
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
//            ZStack {
//                let viewModel = WordBombGameViewModel.preview(numPlayers: 4)
//                Color("Background").ignoresSafeArea(.all)
//                GamePlayView(gkMatch: nil).environmentObject(viewModel)
//
//                VStack {
//
//                    Game.MainButton(label: "ANIMATE") {
//                        viewModel.model.process(Response(input:
//                                                            "Test",
//                                                         status: .Correct,
//                                                         score: 20))
//                    }
//                    Game.MainButton(label: "OUCH") {
//                        viewModel.model.currentPlayerRanOutOfTime()
//                    }
//                }
//            }
//            ZStack {
//                let viewModel = WordBombGameViewModel.preview(numPlayers: 2)
//
//                GamePlayView(gkMatch: nil).environmentObject(viewModel)
//
//                VStack {
//
//                    Game.MainButton(label: "ANIMATE") {
//                        viewModel.model.process(Response(input:
//                                                            "Test",
//                                                         status: .Correct,
//                                                         score: Int.random(in: 1...10)))
//                    }
//                    Game.MainButton(label: "OUCH") {
//                        viewModel.model.currentPlayerRanOutOfTime()
//                    }
//                }
//            }
//            ZStack {
//                let viewModel = WordBombGameViewModel.preview(numPlayers: 1)
//
//                GamePlayView(gkMatch: nil)
//                    .environmentObject(viewModel)
//                    .onAppear { viewModel.arcadeMode = true }
//
//                VStack {
//
//                    Game.MainButton(label: "ANIMATE") {
//                        viewModel.model.process(Response(input:
//                                                            "Test",
//                                                         status: .Correct,
//                                                         score: 20))
//                    }
//                    Game.MainButton(label: "OUCH") {
//                        viewModel.model.currentPlayerRanOutOfTime()
//                    }
//                }
//            }
            
            ZStack {
                let viewModel = WordBombGameViewModel.preview(numPlayers: 1)

//                GamePlayView(gkMatch: nil)
//                    .environmentObject(viewModel)
//                    .onAppear { viewModel.frenzyMode = true }

//                VStack {
//
//                    Game.MainButton(label: "ANIMATE") {
//                        viewModel.model.process(Response(input:
//                                                            "Test",
//                                                         status: .Correct,
//                                                         score: 20))
//                    }
//                    Game.MainButton(label: "OUCH") {
//                        viewModel.model.currentPlayerRanOutOfTime()
//                    }
//                }
            }
            
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
