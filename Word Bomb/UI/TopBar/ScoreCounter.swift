//
//  ScoreCounter.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import SwiftUI

struct ScoreCounter: View {
    @State private var animateScore = true
    @State private var animateDashedBorder = false
    @Binding var score: Int
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "a.square.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .scaledToFit()
                    .scaleEffect(animateScore ? 1 : 1.2)
                    .animation(Game.mainAnimation)
                
                ZStack(alignment: .leading) {
                    
                    Text("\(score)")
                        .boldText()
                        .scaleEffect(animateScore ? 1 : 0)
                        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.4, blendDuration: 0.1))
                        .overlay(
                            Circle()
                                .strokeBorder(style: StrokeStyle(lineWidth: animateDashedBorder ? 0 : 50, lineCap: .butt, dash: [3, 10]))
                                .frame(width: 70, height: 70, alignment: .center)
                                .foregroundColor(.green)
                                .scaleEffect(animateDashedBorder ? 1.2 : 0)
                                .animation(.interactiveSpring().speed(0.4))
                                .opacity(animateDashedBorder ? 0.6 : 0)
                        )
                }
                .onChange(of: score) { newScore in
                    if newScore > 0 {
                        withAnimation {
                            animateScore = false
                            animateDashedBorder = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) {
                                animateScore = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                animateDashedBorder = false
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(ScaleEffect())
    }
}

struct ScoreCounter_Previews: PreviewProvider {
    struct ScoreCounter_Harness: View {
        @State var score = 0
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    ScoreCounter(score: $score, action: {})
                    Button("Plus One") {
                        score += 1
                    }
                    Button("Times Ten") {
                        score *= 10
                    }
                }
            }
        }
    }
    static var previews: some View {
        ScoreCounter_Harness()
    }
}
