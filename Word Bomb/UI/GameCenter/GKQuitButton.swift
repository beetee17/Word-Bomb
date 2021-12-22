//
//  GKQuitButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 23/7/21.
//

import SwiftUI
import GameKitUI

struct GKQuitButton: View {
    @EnvironmentObject var gameViewModel: WordBombGameViewModel
    
    var body: some View {
        // TODO: Add confirmation dialog
        Button(action: {
            Game.playSound(file: "back")
            GameCenter.viewModel.cancel()
            GameCenter.hostPlayerName = nil
            
        }) {
            HStack {
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
                    
                Text("Quit")
            }
            .foregroundColor(.white)
            
        }
    }
}

struct GKQuitButton_Previews: PreviewProvider {
    static var previews: some View {
        GKQuitButton()
    }
}
