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
    @State var timeLimit: Float
    @Binding var animateExplosion: Bool
    
    var body: some View {
        ZStack {
            if players.playing.count != 2 {
                ZStack {
                    BombView(timeLeft: $timeLeft, timeLimit: timeLimit)
                        .frame(width: Game.miniBombSize*1.25, height: Game.miniBombSize*1.25)
                        .overlay(
                            Text(String(format: "%.1f", timeLeft))
                                .offset(x: 5, y: 10))
                    
                    BombExplosion(animating: $animateExplosion)
                        .offset(x: 10, y: 10)
                    // to center explosion on bomb
                }
            }
            
            else {
                Text(String(format: "%.1f", timeLeft))
                    .font(.largeTitle)
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
                
                TimerView(players: .constant(players), timeLeft: .constant(10), timeLimit: 10, animateExplosion: $animateExplosion)

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
