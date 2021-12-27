//
//  GameOverText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI

struct GameOverText: View {
    
    var gameMode: GameMode?
    var numCorrect: Int
    var usedWords: [String]
    var trainingMode: Bool
    
    @State var showMatchReview = false
    
    var body: some View {
        VStack {
            Text("Word Count: \(numCorrect)")
                .boldText()
                .onTapGesture {
                    showMatchReview = true
                }
            
            if trainingMode {
                // If in training mode there better be a Game Mode
                Text("Previous Best: \(gameMode!.highScore)")
                    .boldText()
                    .onAppear() {
                        if numCorrect <= gameMode!.highScore {
                            Game.playSound(file: "explosion")
                        }
                        gameMode!.updateHighScore(with: numCorrect)
                    }
            }
        }
        .if((numCorrect > gameMode?.highScore ?? Int.max) || !trainingMode) { $0.overlay(ConfettiView()) }
        .sheet(isPresented: $showMatchReview) {
            MatchReviewView(mode: gameMode!, usedWords: Set(usedWords))
        }
    }
}

struct GameOverText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameOverText(
                gameMode: .exampleDefault,
                numCorrect: 10,
                usedWords: ["Word1"],
                trainingMode: true
            )
            GameOverText(
                gameMode: .exampleDefault,
                numCorrect: 10,
                usedWords: ["Word1"],
                trainingMode: false
            )
        }
    }
}
