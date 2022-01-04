//
//  ScoreCounter.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import SwiftUI

struct ScoreCounter: View {
    var score: Int
    @ObservedObject var imagePicker: StarImagePicker
    @State private var animateScore = true
    @State private var animateIncrement = false
    @State var increment: Int = 0
    
    var body: some View {
        HStack {
            
            Image(imagePicker.imageName)
                .resizable()
                .frame(width: 25, height: 25)
                .scaledToFit()
                .scaleEffect(animateScore ? 1 : 1.2)
                .animation(animateScore ? nil : Game.mainAnimation)
            
            Text("\(score)")
                .boldText()
                .fixedSize(horizontal: false, vertical: false)
                .scaleEffect(animateScore ? 1 : 1.2)
                .animation(Game.mainAnimation)
                .overlay(
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .scaledToFit()
                        Text("\(increment)")
                            .boldText()
                            .fixedSize(horizontal: false, vertical: false) // prevents text from getting truncated to ...
                    }
                        .frame(width: 150, height: 150)
                        .foregroundColor(.green)
                        .offset(x: 20, y: animateIncrement ? -30 : -20)
                        .animation(.easeIn.speed(0.7))
                        .opacity(animateIncrement ? 0.7 : 0)
                        .animation(.easeInOut.speed(0.7))
                )
                .onChange(of: score) { [score] newValue in
                    if newValue > score {
                        if imagePicker.state != .Combo {
                            // Just do not override combo emote once
                            imagePicker.getImage(for: .Happy)
                        }
                        imagePicker.state = .Happy
                        increment = newValue - score
                        withAnimation {
                            animateScore = false
                            animateIncrement = true
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.075) {
                                self.animateScore = true
                            }
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
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
        @State var imageName = "star-happy0"
        @StateObject var imagePicker = StarImagePicker()
        
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    ScoreCounter(score: score, imagePicker: imagePicker)
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
