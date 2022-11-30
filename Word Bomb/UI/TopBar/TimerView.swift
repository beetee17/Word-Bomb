//
//  TimerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct TimerView: View {
    var viewModel: WordBombGameViewModel = Game.viewModel
    
    var props: Props
    
    @Binding var isAnimatingTimeDelta: Bool
    @Binding var isAnimatingExplosion: Bool
    
    private var rootThreshold: Float { viewModel.frenzyMode ? 10 : 4 }
    private var timeLeft: Float { props.timeLeft }
    private var timeDelta: Int { props.timeDelta }
    private var numPlayers: Int { props.numPlayers }
    
    var body: some View {
        print("Redrawing TimerView")
        return ZStack {
            if numPlayers != 2 {
                BombTimerView(timeLeft: timeLeft,
                              timeLimit: props.timeLimit,
                              isAnimatingExplosion: $isAnimatingExplosion)
                    .if(timeLeft < rootThreshold) { $0.shadow(color: Color.red.opacity(0.7), radius: 1) }
            } else {
                Text(String(format: "%.1f", timeLeft))
                    .font(.largeTitle)
                    .offset(y: Device.height*0.015)
            }
        }
        .animatingIncrement(timeDelta, isAnimating: $isAnimatingTimeDelta)
        .if(timeLeft < rootThreshold) { $0.pulseEffect() }
        .onChange(of: timeLeft) { newValue in
            if newValue > 0 && newValue < rootThreshold  {
                AudioPlayer.playROOTSound()
            }
        }
    }
}

extension TimerView {
    struct Props {
        var frenzyMode: Bool
        
        var timeLeft: Float
        var timeLimit: Float
        var timeDelta: Int
        
        var numPlayers: Int
    }
}

extension TopBarView.Props {
    var timerViewProps: TimerView.Props {
        .init(frenzyMode: frenzyMode,
              timeLeft: timeLeft,
              timeLimit: timeLimit,
              timeDelta: timeDelta,
              numPlayers: numPlayers)
    }
}

struct BombTimerView: View {
    var timeLeft: Float
    var timeLimit: Float
    
    @Binding var isAnimatingExplosion: Bool
    
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


            BombExplosion(animating: $isAnimatingExplosion)
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
            let viewModel = WordBombGameViewModel.preview(numPlayers: numPlayers)
            VStack {

                TimerView(props: viewModel.topBarViewProps.timerViewProps,
                          isAnimatingTimeDelta: .constant(false),
                          isAnimatingExplosion: $animateExplosion)
                    .environmentObject(viewModel)

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
