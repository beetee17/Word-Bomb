//
//  PauseMenuView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI


struct PauseMenuView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {
        
        
        VStack(spacing: 100) {
            // RESUME, RESTART, QUIT buttons
            Game.mainButton(label: "RESUME", systemImageName: "play") {
                viewModel.resumeGame()
            }
            Game.mainButton(label: "RESTART", systemImageName: "gobackward") {
                viewModel.restartGame()
            }
            Game.mainButton(label: "QUIT", systemImageName: "flag", sound: "back") {
                viewModel.viewToShow = .main
            }
        }
    }
}

struct PauseMenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        PauseMenuView()
            .environmentObject(WordBombGameViewModel())
    }
}
