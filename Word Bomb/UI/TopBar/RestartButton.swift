//
//  RestartButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct RestartButton: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {
        Button(action: {
            print("Restart Game")
            if !GameCenter.isNonHost {
                // do not allow restart for non host in online match
                viewModel.restartGame()
            } else {
                Game.errorHandler.showBanner(title: "Unable To Restart Game", message: "Only the host (\(String(describing: GameCenter.hostPlayerName))) is able to do so!")
            }
        }) {
            Image(systemName: "gobackward")
                .resizable().aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
        }
    }
}

struct RestartButton_Previews: PreviewProvider {
    static var previews: some View {
        RestartButton()
            .environmentObject(WordBombGameViewModel())
    }
}
