//
//  TimerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    private var rootThreshold: Float { viewModel.frenzyMode ? 10 : 4 }
    private var timeLeft: Float { viewModel.model.controller.timeLeft }
    private var timeDelta: Int { viewModel.model.controller.timeDelta }
    private var numPlayers: Int { viewModel.model.players.playing.count }
    
    var body: some View {
        
        ZStack {
            if numPlayers != 2 {
                BombTimerView()
                    .if(timeLeft < rootThreshold) { $0.shadow(color: Color.red.opacity(0.7), radius: 1) }
            } else {
                Text(String(format: "%.1f", timeLeft))
                    .font(.largeTitle)
                    .offset(y:Device.height*0.015)
            }
        }
        .animatingIncrement(timeDelta, isAnimating: $viewModel.model.controller.animateTimeDelta)
        .if(timeLeft < rootThreshold) { $0.pulseEffect() }
        .onChange(of: timeLeft) { newValue in
            if newValue > 0 && newValue < rootThreshold  {
                AudioPlayer.playROOTSound()
            }
        }
    }
}

struct BombTimerView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    private var timeLeft: Float { viewModel.model.controller.timeLeft }
    private var timeLimit: Float { viewModel.model.controller.timeLimit }
    
    var body: some View {

        ZStack {
            BombView(timeLeft: timeLeft, timeLimit: timeLimit)
                .frame(width: Game.miniBombSize*1.25, height: Game.miniBombSize*1.25)
                .overlay(
                    Text(String(format: "%.1f", timeLeft))
                        .offset(x: 5, y: 10)
                        .shadow(color: .black.opacity(1), radius: 1)
                        .shadow(color: .black.opacity(1), radius: 1)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                        .shadow(color: .black.opacity(0.4), radius: 1)
                )


            BombExplosion(animating: $viewModel.model.controller.animateExplosion)
                .offset(x: 10, y: 10)
            // to center explosion on bomb
        }
    }
}

struct TimerView_Previews: PreviewProvider {

    struct TimerView_Harness: View {
        var numPlayers: Int
        @State private var animateExplosion  = false

        var body: some View {
            VStack {

                TimerView().environmentObject(WordBombGameViewModel.preview(numPlayers: numPlayers))

                Button("Test Explosion!") {
                    animateExplosion = true
                    AudioPlayer.playSound(.Explosion)
                }
            }
        }
    }
    static var previews: some View {
        Group {
            TimerView_Harness(numPlayers: 3)
            TimerView_Harness(numPlayers: 2)
        }
    }
}
