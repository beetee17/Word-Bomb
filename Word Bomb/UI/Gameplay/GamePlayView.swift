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
    
    @State var showMatchProgress = false
    @State var showUsedLetters = false
    @State var gamePaused = false
    @State var forceHideKeyboard = false
    
    var gkMatch: GKMatch?
    
    var body: some View {
        ZStack {
            ZStack {
                Color.clear
                
                VStack {
                    TopBarView(gamePaused: $gamePaused,
                               showMatchProgress: $showMatchProgress,
                               showUsedLetters: $showUsedLetters,
                               gkMatch: gkMatch)
                    Spacer()
                }
                .zIndex(1)
                
                VStack {
                    PlayerView()
                        .padding(.top, Device.height*0.085)
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            
            VStack(spacing:5) {
                Spacer()
                switch viewModel.model.gameState {
                case .GameOver:
                    GameOverText()
                case .TieBreak:
                    Text("TIED!").boldText()
                    Text("Tap to Continue").boldText()
                default:
                    Text(viewModel.model.instruction ).boldText()
                    Text(viewModel.model.query ?? "").boldText()
                    PermanentKeyboard(
                        text: $viewModel.input,
                        forceResignFirstResponder: $forceHideKeyboard
                    ) {
                        viewModel.processInput()
                    }
                    .font(Font.system(size: 20))
                }
                
                OutputText(text: $viewModel.model.output)
                Spacer()
            }
            .offset(y: Device.height*0.03)
            .ignoresSafeArea(.all)
        }
        .blur(radius: gamePaused || showMatchProgress || showUsedLetters ? 10 : 0, opaque: false)
        .overlay(
            MatchProgressView(usedWords: viewModel.model.game?.usedWords.sorted(), showMatchProgress: $showMatchProgress)
        )
        .overlay(PauseMenuView(gamePaused: $gamePaused))
        .overlay(AlphabetTracker(usedLetters: viewModel.model.players.current.usedLetters, isShowing: $showUsedLetters))
        .onChange(of: gamePaused) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showMatchProgress) { newValue in
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

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ZStack {
                let viewModel = WordBombGameViewModel.preview(numPlayers: 4)
                
                GamePlayView(gkMatch: nil).environmentObject(viewModel)
                
                VStack {
                    Spacer()
                    Game.MainButton(label: "ANIMATE") {
                        viewModel.model.process(Response(input:
                                                            "Test",
                                                         status: .Correct,
                                                         score: 20))
                    }
                    Game.MainButton(label: "OUCH") {
                        viewModel.model.currentPlayerRanOutOfTime()
                    }
                }
            }
            ZStack {
                let viewModel = WordBombGameViewModel.preview(numPlayers: 2)
                
                GamePlayView(gkMatch: nil).environmentObject(viewModel)
                
                VStack {
                    Spacer()
                    Game.MainButton(label: "ANIMATE") {
                        viewModel.model.process(Response(input:
                                                            "Test",
                                                         status: .Correct,
                                                         score: Int.random(in: 1...10)))
                    }
                    Game.MainButton(label: "OUCH") {
                        viewModel.model.currentPlayerRanOutOfTime()
                    }
                }
            }
            ZStack {
                let viewModel = WordBombGameViewModel.preview(numPlayers: 1)
                
                GamePlayView(gkMatch: nil).environmentObject(viewModel)
                
                VStack {
                    Spacer()
                    Game.MainButton(label: "ANIMATE") {
                        viewModel.model.process(Response(input:
                                                            "Test",
                                                         status: .Correct,
                                                         score: 20))
                    }
                    Game.MainButton(label: "OUCH") {
                        viewModel.model.currentPlayerRanOutOfTime()
                    }
                }
            }
            
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
