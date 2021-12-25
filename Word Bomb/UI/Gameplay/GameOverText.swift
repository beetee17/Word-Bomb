//
//  GameOverText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI

struct GameOverText: View {
    
    var gameMode: GameMode
    var numCorrect: Int
    var trainingMode: Bool
    
    var body: some View {
        VStack {
            Text("Word Count: \(numCorrect)")
                .boldText()
            
            if trainingMode {
                Text("Previous Best: \(gameMode.highScore)")
                    .boldText()
                    .onAppear() {
                        if numCorrect <= gameMode.highScore {
                            Game.playSound(file: "explosion")
                        }
                        gameMode.updateHighScore(with: numCorrect)
                    }
            }
        }
        .if(numCorrect > gameMode.highScore || !trainingMode) { $0.overlay(ConfettiView()) }
    }
}

struct GameOverText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameOverText(gameMode: .exampleDefault, numCorrect: 10, trainingMode: true)
            GameOverText(gameMode: .exampleDefault, numCorrect: 10, trainingMode: false)
        }
    }
}
