//
//  GKQuitButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 23/7/21.
//

import SwiftUI
import GameKitUI

struct GKQuitButton: View {

    var body: some View {
        // TODO: Add confirmation dialog
        Button(action: {
            AudioPlayer.playSound(.Cancel)
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
        .buttonStyle(ScaleEffect())
    }
}

struct GKQuitButton_Previews: PreviewProvider {
    static var previews: some View {
        GKQuitButton()
    }
}
