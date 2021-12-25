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
                numPlayers: viewModel.players.queue.count,
                timeLeft: $viewModel.timeLeft,
                timeLimit: viewModel.timeLimit,
                gameState: $viewModel.gameState,
                playRunningOutOfTimeSound: $viewModel.playRunningOutOfTimeSound
            )
                .offset(x: gkMatch == nil ? 0 : -20)
            
            Spacer()
            
            if .gameOver == viewModel.gameState { RestartButton() }
            else if viewModel.totalWords < 1000 {
                Text("\(viewModel.numCorrect)/\(viewModel.totalWords)")
            } else {
                Text("\(viewModel.numCorrect)")
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
