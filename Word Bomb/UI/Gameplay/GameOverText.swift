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
    @State var prevBest: Int
    
    var body: some View {
        let usedWords = viewModel.model.game.usedWords
        let score = viewModel.model.players.current.score
        let singlePlayer = viewModel.arcadeMode || viewModel.frenzyMode
        let gameMode = viewModel.gameMode
        
        VStack {
            Game.MainButton(label: "Match Review", systemImageName: "doc.text.magnifyingglass") {
                    showMatchReview = true
                }
            
            if singlePlayer {
                // If in training mode there better be a Game Mode
                Text("Previous Best: \(prevBest)")
                    .boldText()
                    .onAppear() {
                        if score <= prevBest {
                            AudioPlayer.playSound(.Explosion)
                        } else if viewModel.arcadeMode {
                            gameMode!.updateArcadeHighScore(with: score)
                        } else {
                            gameMode!.updateFrenzyHighScore(with: score)
                        }
                    }
            }
        }
        .if(showConfetti) { $0.overlay(ConfettiView()) }
        .sheet(isPresented: $showMatchReview) {
            MatchReviewView(words: viewModel.model.game.words,  usedWords: Set(usedWords ?? []), numCorrect: viewModel.model.numCorrect, totalWords: viewModel.model.game.totalWords)
        }
        .onAppear() {
            if (score > prevBest) || !singlePlayer {
                showConfetti = true
            }
        }
    }
}

struct GameOverText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameOverText(prevBest: 0).environmentObject(WordBombGameViewModel())
            GameOverText(prevBest: 0).environmentObject(WordBombGameViewModel())
        }
    }
}
