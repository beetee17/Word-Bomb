//
//  TimerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct TimerView: View {
    // TODO: why are bindings needed
    @Binding var players: Players
    @Binding var timeLeft: Float
    @Binding var timeLimit: Float
    @Binding var animateExplosion: Bool
    var rootThreshold: Float
    @State private var animateIncrement = false
    @State private var increment = 5
    
    var body: some View {
        ZStack {
            if players.playing.count != 2 {
                ZStack {
                    BombView(timeLeft: $timeLeft, timeLimit: timeLimit)
                        .frame(width: Game.miniBombSize*1.25, height: Game.miniBombSize*1.25)
                        .if(timeLeft < rootThreshold) { $0.shadow(color: Color.red, radius: 2) }
                        .overlay(
                            Text(String(format: "%.1f", timeLeft))
                                .offset(x: 5, y: 10)
                                .shadow(color: .black.opacity(1), radius: 1)
                                .shadow(color: .black.opacity(1), radius: 1)
                                .shadow(color: .black.opacity(0.4), radius: 1)
                                .shadow(color: .black.opacity(0.4), radius: 1)
                        )
                        
                    
                    BombExplosion(animating: $animateExplosion)
                        .offset(x: 10, y: 10)
                    // to center explosion on bomb
                }
            }
            
            else {
                Text(String(format: "%.1f", timeLeft))
                    .font(.largeTitle)
                    .offset(y:Device.height*0.015)
                    
            }
        }
        .animatingIncrement(increment, isAnimating: animateIncrement, xOffset: 40.0)
        .if(timeLeft < rootThreshold) { $0.pulseEffect() }
        .onChange(of: timeLimit) { [timeLimit] newValue in
            if Int(newValue - timeLimit) == 5 {
                // TODO: get rid of this hack
                increment = 5
                animateIncrement = true
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                    animateIncrement = false
                }
            }
        }
        .onChange(of: timeLeft) { [timeLeft] newValue in
            if newValue > 0 && newValue < rootThreshold  && Int(newValue) != Int(timeLimit) {
                AudioPlayer.playROOTSound()
            }
            if abs(newValue - timeLeft) > 1  && Int(newValue) != Int(timeLimit) {
                // TODO: get rid of this hack
                increment = Int(newValue - timeLeft)
                animateIncrement = true
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                    animateIncrement = false
                }
            }
        }
    }
}


struct TimerView_Previews: PreviewProvider {

    struct TimerView_Harness: View {
        var numPlayers: Int
        @State private var animateExplosion  = false
        
        var body: some View {
            VStack {
                let players = Players(from: (1...numPlayers).map({"\($0)"}))
                
                TimerView(players: .constant(players),
                          timeLeft: .constant(100),
                          timeLimit: .constant(100),
                          animateExplosion: $animateExplosion,
                          rootThreshold: 4)

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
