//
//  PauseMenuView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI


struct PauseMenuView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @Binding var gamePaused: Bool
    var body: some View {
        
        
        VStack(spacing: 100) {
            // RESUME, RESTART, QUIT buttons
            Game.MainButton(label: "RESUME", systemImageName: "play") {
                viewModel.resumeGame()
                gamePaused = false
            }
            Game.MainButton(label: "RESTART", systemImageName: "gobackward") {
                viewModel.restartGame()
                gamePaused = false
            }
            Game.MainButton(label: "QUIT", systemImageName: "flag", sound: .Cancel) {
                viewModel.viewToShow = .Main
            }
        }
        .if(gamePaused) { $0.helpButton() }
        .scaleEffect(gamePaused ? 1 : 0)
        .opacity(gamePaused ? 1 : 0)
        .ignoresSafeArea(.all)
    }
}

struct PauseMenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        PauseMenuView(gamePaused: .constant(true))
            .environmentObject(WordBombGameViewModel())
    }
}
