//
//  PauseMenuView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI


struct PauseMenuView: View {
    // Presented when game is paused
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    
    var body: some View {
        
        
        VStack(spacing: 100) {
            // RESUME, RESTART, QUIT buttons
            Game.mainButton(label: "RESUME", systemImageName: "play") {
                viewModel.resumeGame()
            }
            Game.mainButton(label: "RESTART", systemImageName: "gobackward") {
                viewModel.restartGame()
            }
            
            Game.mainButton(label: "QUIT", systemImageName: "flag") {
                viewModel.viewToShow = .main
            }
        }
    }
}

struct PauseMenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        PauseMenuView()
    }
}
