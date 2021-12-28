//
//  GameOverText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI

struct GameOverText: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @State var showMatchReview = false

    var body: some View {
        let usedWords = viewModel.model.game?.usedWords
        let numCorrect = usedWords?.count ?? 0
        let trainingMode = viewModel.trainingMode
        let gameMode = viewModel.gameMode
        
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
        .overlay(ConfettiView())
        .if((numCorrect > gameMode?.highScore ?? Int.max) || !trainingMode) { $0.overlay(ConfettiView()) }
        .sheet(isPresented: $showMatchReview) {
            MatchReviewView(words: viewModel.model.game?.words,  usedWords: Set(usedWords ?? []), totalWords: viewModel.model.game!.totalWords)
        }
    }
}

struct GameOverText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameOverText().environmentObject(WordBombGameViewModel())
            GameOverText().environmentObject(WordBombGameViewModel())
        }
    }
}
