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
    @State var gamePaused = false
    @State var forceHideKeyboard = false
    var gkMatch: GKMatch?
    
    var body: some View {
        ZStack {
            
            // for debugging preview
            //                ZStack {
            //                    Button("ANIMATE") {
            //                        viewModel.animate.toggle()
            //                    }
            //                }
            //                .padding(.top,200)
            ZStack {
                Color.clear
                
                VStack {
                    TopBarView(gamePaused: $gamePaused, showMatchProgress: $showMatchProgress, gkMatch: gkMatch)
                        
                    Spacer()
                }
                
                VStack {
                    PlayerView()
                        .padding(.top, Device.height*0.075)
                    Spacer()
                }
                
            }
            .ignoresSafeArea(.keyboard)
            
            VStack(spacing:5) {
                Spacer()
                if viewModel.model.gameState == .gameOver {
                    GameOverText()
                } else {
                    
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
            .offset(y: Device.height*0.075)
            .ignoresSafeArea(.all)
        }
        .blur(radius: gamePaused || showMatchProgress ? 10 : 0, opaque: false)
        .overlay(
            MatchProgressView(usedWords: viewModel.model.game?.usedWords.sorted(), showMatchProgress: $showMatchProgress)
        )
        .overlay(PauseMenuView(gamePaused: $gamePaused))
        .onChange(of: gamePaused) { newValue in
            forceHideKeyboard = newValue
        }
        .onChange(of: showMatchProgress) { newValue in
            forceHideKeyboard = newValue
        }
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 3))
            
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 2))
            
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 1))
        }
        .background(Color("Background").ignoresSafeArea())
    }
}
