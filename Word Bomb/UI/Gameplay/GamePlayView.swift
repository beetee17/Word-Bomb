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
                    TopBarView(gkMatch: gkMatch)
                        
                    Spacer()
                }
                
                VStack {
                    PlayerView()
                        .padding(.top, Device.height*0.1)
                    Spacer()
                }
                
            }
            .ignoresSafeArea(.keyboard)
            
            VStack {
                Spacer()
                if viewModel.model.gameState == .gameOver {
                    GameOverText(
                        gameMode: viewModel.gameMode,
                        numCorrect: viewModel.model.numCorrect,
                        trainingMode: viewModel.trainingMode)
                    
                } else {
                    Text(viewModel.model.instruction ).boldText()
                    Text(viewModel.model.query ?? "").boldText()
                    PermanentKeyboard(text: $viewModel.input, forceResignFirstResponder: $viewModel.forceHideKeyboard) {
                        viewModel.processInput()
                    }
                    .font(Font.system(size: 20))
                }
                
                OutputText(text: $viewModel.model.output)
                
                Spacer()
            }
            .offset(y: Device.height*0.05)
            .ignoresSafeArea(.all)
        }
        .blur(radius: .pauseMenu == viewModel.viewToShow ? 10 : 0, opaque: false)
    }
}

struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 3))
            
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 2))
            
            GamePlayView(gkMatch: nil).environmentObject(WordBombGameViewModel.preview(numPlayers: 1))
        }
    }
}
