//
//  TopBarView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI
import GameKit

struct TopBarView: View {
    // Appears in game screen for user to access pause menu, restart a game
    // and see current time left
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var gkMatch: GKMatch?
    
    var body: some View {
        
        HStack {
            
            switch gkMatch == nil {
            case true:
                PauseButton()
            case false:
                GKQuitButton()
            }

            Spacer()
            
            TimerView()
                .offset(x: gkMatch == nil ? 0 : -20)
            
            Spacer()
            
            if .gameOver == viewModel.gameState { RestartButton().opacity(1) }
            else { RestartButton().opacity(0) }
        }
        .padding(.horizontal, 20)
        .padding(.top, viewModel.playerQueue.count > 2 ? 0 : 50)
        
    }
    
    
}


struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView().environmentObject(WordBombGameViewModel())
    }
}
