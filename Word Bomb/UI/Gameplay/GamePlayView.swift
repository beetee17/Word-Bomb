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
    
    var instructionText: some View {
        viewModel.instruction.map { Text($0)
                .boldText()
            
        }
    }
    var queryText: some View {
        viewModel.query.map { Text($0)
                .boldText()
        }
    }
    
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
                        .onChange(of: viewModel.timeLeft) { time in
                            print("time: \(time)")
                            if time < 3 && !viewModel.playRunningOutOfTimeSound{
                                // do not interrupt if explosion sound is playing
                                if !(Game.audioPlayer?.isPlaying ?? false) {
                                    Game.playSound(file: "hissing")
                                    viewModel.playRunningOutOfTimeSound = true
                                }
                            }
                        }
                    Spacer()
                }
                
                VStack {
                    PlayerView()
                        .offset(x: 0, y: Device.height*0.1)
                    Spacer()
                }
                
            }
            .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                if viewModel.gameState == .gameOver {
                    Text("Word Count: \(viewModel.numCorrect)")
                        .boldText()
                } else {
                    instructionText
                    queryText
                    PermanentKeyboard(text: $viewModel.input, forceResignFirstResponder: $viewModel.forceHideKeyboard) {
                        viewModel.processInput()
                    }
                    .font(Font.system(size: 20))
                }
                
                OutputText()
                
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
        GamePlayView(gkMatch: GKMatch()).environmentObject(WordBombGameViewModel())
    }
}
