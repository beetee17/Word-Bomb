//
//  TimerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct TimerView: View {
    @State var numPlayers: Int
    @Binding var timeLeft: Float
    @State var timeLimit: Float
    @Binding var gameState: GameState
    
    var body: some View {
        if numPlayers != 2 {
            ZStack {
                BombView(timeLeft: $timeLeft, timeLimit: timeLimit)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(String(format: "%.1f", timeLeft))
                            .offset(x: 5, y: 10))
                
                BombExplosion(gameState: $gameState)
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


struct TimerView_Previews: PreviewProvider {
    
    struct TimerView_Harness: View {
        
        var numPlayers: Int
        @State private var gameState: GameState = .playing
        
        var body: some View {
            VStack {
                TimerView(numPlayers: numPlayers, timeLeft: .constant(10), timeLimit: 10, gameState: $gameState)

                Button("Test Explosion!") {
                    gameState = .playerTimedOut
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        gameState = .playing
                    }
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
