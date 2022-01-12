//
//  TopBarView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI
import GameKit

struct TopBarView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @Binding var gamePaused: Bool
    @Binding var showMatchProgress: Bool
    @Binding var showUsedLetters: Bool
    
    var gkMatch: GKMatch?
    
    var body: some View {
        
        HStack {
            Spacer()
                .overlay(
                    TopLeft(gamePaused: $gamePaused,
                            gkMatch: gkMatch)
                )
                .frame(width:Device.width*0.2)
                .offset(y:Device.height*0.015)
            
            TimerView()
                .offset(x: gkMatch == nil ? 0 : -20)
                .frame(width:Device.width*0.5)
                .offset(x:Device.width*0.05)
             
            Spacer()
                .overlay(
                    TopRight(showMatchProgress: $showMatchProgress,
                             showUsedLetters: $showUsedLetters)
                )
                .offset(y:Device.height*0.015)
        }
        // The top bar is smaller when there are less than 3 players due to the bomb explosion animation.
        .frame(height: Game.miniBombSize*1.5)
        .offset(x: 0,y: -Device.height*0.04)
    }
}


struct TopLeft: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @Binding var gamePaused: Bool
    var gkMatch: GKMatch?
    
    var body: some View {
        ZStack {
            switch gkMatch == nil {
            case true:
                PauseButton(gamePaused: $gamePaused)
            case false:
                GKQuitButton()
            }
        }
    }
}
struct TopRight: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @Binding var showMatchProgress: Bool
    @Binding var showUsedLetters: Bool
    
    var body: some View {
        let singlePlayer = viewModel.frenzyMode || viewModel.arcadeMode
        
        ZStack {
            if .GameOver == viewModel.model.gameState {
                RestartButton()
            } else if !singlePlayer && !showMatchProgress {
                CorrectCounter(
                    numCorrect: viewModel.model.numCorrect,
                    action: { showMatchProgress.toggle() })
            } else if singlePlayer && !showUsedLetters {
                UsedLettersCounter(usedLetters: viewModel.model.players.current.usedLetters,
                                   showUsedLetters: $showUsedLetters)
            }
        }
    }
}

    
    
struct TopBarView_Previews: PreviewProvider {
    
    struct TopBarView_Harness: View {
        @ObservedObject var viewModel = WordBombGameViewModel()
        
        var body: some View {
            VStack {
                TopBarView(gamePaused: .constant(false),
                           showMatchProgress: .constant(false),
                           showUsedLetters: .constant(false))
                    .environmentObject(viewModel)
                Game.MainButton(label: "1", systemImageName: "plus.circle") {
                    viewModel.model.numCorrect += 1
                }
                Game.MainButton(label: "10", systemImageName: "multiply.circle") {
                    viewModel.model.numCorrect *= 10
                }
            }
            .background(Color("Background"))
        }
    }
    static var previews: some View {
        TopBarView_Harness()
    }
}
