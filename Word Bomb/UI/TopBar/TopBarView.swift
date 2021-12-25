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
                timeLeft: $viewModel.model.timeLeft,
                timeLimit: viewModel.model.timeLimit,
                animateExplosion: $viewModel.model.animateExplosion,
                playRunningOutOfTimeSound: $viewModel.model.playRunningOutOfTimeSound
            )
                .offset(x: gkMatch == nil ? 0 : -20)
            
            Spacer()
            
            if .gameOver == viewModel.model.gameState { RestartButton() }
            else if viewModel.totalWords < 1000 {
                Text("\(viewModel.model.numCorrect)/\(viewModel.totalWords)")
            } else {
                Text("\(viewModel.model.numCorrect)")
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
        TopBarView().environmentObject(WordBombGameViewModel())
    }
}
