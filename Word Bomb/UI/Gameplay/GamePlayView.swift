//
//  GamePlayView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 14/7/21.
//

import SwiftUI
import GameKit
import GameKitUI

struct GamePlayView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @ObservedObject var IAPHandler = UserViewModel.shared
    @State var showMatchProgress = false
    @State var showUsedLetters = false
    @State var gamePaused = false
    @State var forceHideKeyboard = false
    
    var gkMatch: GKMatch?
    
    var body: some View {
        ZStack {
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
                        
                        PlayerView(props: viewModel.playerViewProps)
                            .offset(y: -Device.height*0.05)
                        
                        
                        Spacer()
                    }
                }
            }

            GamePlayArea(props: viewModel.gamePlayAreaProps,
                         input: $viewModel.input,
                         output: $viewModel.model.output,
                         forceHideKeyboard: $forceHideKeyboard)
                .ignoresSafeArea(.all)
        }
    
        .blur(radius: gamePaused || showMatchProgress || showUsedLetters ? 10 : 0, opaque: false)
        .overlay(
            MatchProgressView(usedWords: viewModel.model.game.usedWords.sorted(), showMatchProgress: $showMatchProgress)
        )
        .overlay(PauseMenuView(gamePaused: $gamePaused))
        .overlay(AlphabetTracker(usedLetters: viewModel.model.players.current.usedLetters, isShowing: $showUsedLetters))
        .onChange(of: gamePaused) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showMatchProgress) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showUsedLetters) { newValue in
            forceHideKeyboard = newValue
        }
        .if(viewModel.model.gameState == .TieBreak && !GameCenter.isNonHost) {
            // Do not allow non host to resume the tie breaker
            $0.onTapGesture {
                viewModel.startTimer()
                viewModel.model.handleGameState(.Playing)
            }
        }
    }
}


struct GamePlayArea: View {
    
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
    struct Props {
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

                GamePlayView(gkMatch: nil)
                    .environmentObject(viewModel)
                    .onAppear { viewModel.frenzyMode = true }

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
