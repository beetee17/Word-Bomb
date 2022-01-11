//
//  CorrectCounter.swift
//  Word Bomb
//
//  Created by Brandon Thio on 3/1/22.
//

import SwiftUI

struct CorrectCounter: View {
    var numCorrect: Int
    var action: () -> Void
    @State private var animate = true
    var letterToShow = "w"
    
    var body: some View {
        
        Button(action: {
            AudioPlayer.playSound(.Select)
            action()
        }) {
            HStack {
                
                Image(systemName: "\(letterToShow.lowercased()).square.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .scaledToFit()
                    .scaledToFit()
                    .scaleEffect(animate ? 1 : 1.2)
                    .animation(Game.mainAnimation)
                
                ZStack(alignment: .leading) {
                    
                    Text("\(numCorrect)")
                        .boldText()
                        .scaleEffect(animate ? 1 : 1.2)
                        .animation(Game.mainAnimation)
                }
                .onChange(of: numCorrect) { [numCorrect] newValue in
                    if newValue > numCorrect {
                        withAnimation {
                            animate = false
                            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
                                self.animate = true
                            }
                            
                        }
                    }
                }
            }
        }
        .buttonStyle(ScaleEffect())
    }
}

struct CorrectCounter_Previews: PreviewProvider {
    struct CorrectCounter_Harness: View {
        @State var numCorrect = 0
        @State var showReward = false
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    
                    CorrectCounter(numCorrect: numCorrect, action: { withAnimation(.easeInOut) { showReward.toggle() } })
                    
                    Game.MainButton(label: "Plus One") {
                        numCorrect += 1
                    }
                    Game.MainButton(label: "Times Ten") {
                        numCorrect *= 10
                    }
                }
            }
        }
    }
    static var previews: some View {
        CorrectCounter_Harness()
    }
}

