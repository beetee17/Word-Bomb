//
//  PauseButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct PauseButton: View {
    @Binding var gamePaused: Bool
    
    var body: some View {
        
        Button(action: {
            print("Pause Game")
            // delay to allow keyboard to fully hide first -> may mean less responsiveness as user
            withAnimation(.spring(response:0.1, dampingFraction:0.6).delay(0.15)) {
                pauseGame()
            }
        }) {
            
            Image(systemName: "pause")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
        }
        .buttonStyle(ScaleEffect())
    }
    
    /// Pauses the current game
    func pauseGame() {
        gamePaused = true
        AudioPlayer.playSound(.Cancel)
        Game.stopTimer()
    }
}
struct PauseButton_Previews: PreviewProvider {
    static var previews: some View {
        PauseButton(gamePaused: .constant(false))
    }
}
