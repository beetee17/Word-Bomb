//
//  PauseButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct PauseButton: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {
        Button(action: {
            print("Pause Game")
            // delay to allow keyboard to fully hide first -> may mean less responsiveness as user
            withAnimation(.spring(response:0.1, dampingFraction:0.6).delay(0.15)) {
                viewModel.pauseGame()

            }
        }) {
            
            Image(systemName: "pause")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
        }
    }
}
struct PauseButton_Previews: PreviewProvider {
    static var previews: some View {
        PauseButton()
    }
}
