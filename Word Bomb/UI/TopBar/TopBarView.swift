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
    @Binding var showMatchProgress: Bool
    var gkMatch: GKMatch?
    
    var body: some View {
        
        HStack {
            
            switch gkMatch == nil {
            case true:
                PauseButton(viewToShow: $viewModel.viewToShow)
            case false:
                GKQuitButton()
            }

            Spacer()
            
            TimerView(
                players: $viewModel.model.players,
                timeLeft: $viewModel.model.timeKeeper.timeLeft,
                timeLimit: viewModel.model.timeKeeper.timeLimit,
                animateExplosion: $viewModel.model.media.animateExplosion,
                playRunningOutOfTimeSound: $viewModel.model.media.playRunningOutOfTimeSound
            )
                .offset(x: gkMatch == nil ? 0 : -20)
            
            Spacer()
            
            if .gameOver == viewModel.model.gameState {
                RestartButton()
            } else if !showMatchProgress {
                Button("\(viewModel.model.game?.usedWords.count ?? 0)") {
                    showMatchProgress.toggle()
                }
                .foregroundColor(.white)
            }
            
        }
        .padding(.horizontal, 20)
        // The top bar is smaller when there are less than 3 players due to the bomb explosion animation.
        .frame(height: Game.miniBombSize*1.5)
        .offset(x: 0,y: -Device.height*0.03)
    }
}


struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(showMatchProgress: .constant(false)).environmentObject(WordBombGameViewModel())
    }
}
