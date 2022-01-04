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
    @State var showConfetti = false
    
    var body: some View {
        let usedWords = viewModel.model.game?.usedWords
        let score = viewModel.model.players.current.score
        let trainingMode = viewModel.trainingMode
        let gameMode = viewModel.gameMode
        
        VStack {
            Game.MainButton(label: "Match Review", systemImageName: "doc.text.magnifyingglass") {
                    showMatchReview = true
                }
            
            if trainingMode {
                // If in training mode there better be a Game Mode
                Text("Previous Best: \(gameMode!.highScore)")
                    .boldText()
                    .onAppear() {
                        if score <= gameMode!.highScore {
                            AudioPlayer.playSound(.Explosion)
                        }
                    }
            }
        }
        .if(showConfetti) { $0.overlay(ConfettiView()) }
        .sheet(isPresented: $showMatchReview) {
            MatchReviewView(words: viewModel.model.game?.words,  usedWords: Set(usedWords ?? []), numCorrect: viewModel.model.numCorrect, totalWords: viewModel.model.game!.totalWords)
        }
        .onAppear() {
            if (score > gameMode?.highScore ?? Int.max) || !trainingMode {
                showConfetti = true
            }
        }
        .onDisappear() {
            if trainingMode {
                gameMode!.updateHighScore(with: score)
            }
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
