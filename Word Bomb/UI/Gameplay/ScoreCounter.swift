//
//  ScoreCounter.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import SwiftUI

struct ScoreCounter: View {
    var score: Int
    @State private var animateScore = true
    @State private var animateIncrement = false
    @State var increment: Int = 0
    
    var body: some View {
        HStack {
            
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .scaledToFit()
                .foregroundColor(.yellow)
                .scaledToFit()
                .scaleEffect(animateScore ? 1 : 1.2)
                .animation(animateScore ? nil : Game.mainAnimation)
            
            ZStack(alignment: .leading) {
                
                Text("\(score)")
                    .boldText()
                    .scaleEffect(animateScore ? 1 : 1.2)
                    .animation(Game.mainAnimation)
            }
            .overlay(
                HStack {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                    Text("\(increment)")
                        .boldText()
                    
                }
                    .frame(width: 250, height: 250)
                    .foregroundColor(.green)
                    .offset(x: 30, y: animateIncrement ? -40 : -20)
                    .animation(.easeIn.speed(0.7))
                    .opacity(animateIncrement ? 1 : 0)
                    .animation(.easeInOut.speed(2))
            )
            .onChange(of: score) { [score] newValue in
                if newValue > score {
                    increment = newValue - score
                    withAnimation {
                        animateScore = false
                        animateIncrement = true
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.075) {
                            self.animateScore = true
                        }
                        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.2) {
                            self.animateIncrement = false
                        }
                    }
                }
            }
        }
        
    }
}

struct ScoreCounter_Previews: PreviewProvider {
    struct ScoreCounter_Harness: View {
        @State var score = 0
        @State var animate = false
        
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    ScoreCounter(score: score)
                    Button("Plus One") {
                        score += 1
                        animate = true
                    }
                    Button("Times Ten") {
                        score *= 10
                        animate = true
                    }
                }
            }
        }
    }
    static var previews: some View {
        ScoreCounter_Harness()
    }
}
