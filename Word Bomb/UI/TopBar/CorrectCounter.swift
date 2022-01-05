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
    
    var body: some View {
        
        Button(action: {
            AudioPlayer.playSound(.Select)
        }) {
            HStack {
                
                Image(systemName: "w.square.fill")
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

struct RewardOptions: View {
    @State var isShowing: Bool
    var addLiveAction: () -> Void
    var addTimeAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if isShowing {
                Button(action: addTimeAction) {
                    Image(systemName: "heart.fill")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                        .transition(.offset(y:-45).combined(with: .opacity))
                        .shadow(color: .green.opacity(0.5), radius: 3)
                        .pulseEffect()
                }
                .buttonStyle(ScaleEffect())
                .onTapGesture { AudioPlayer.playSound(.Combo) }
                
                Button(action: addTimeAction) {
                    Image(systemName: "stopwatch")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .transition(.offset(y: -75).combined(with: .opacity))
                        .shadow(color: .green.opacity(0.7), radius: 3)
                        .pulseEffect()
                }
                .buttonStyle(ScaleEffect())
                .onTapGesture { AudioPlayer.playSound(.Combo) }
                
            }
        }
        .background(Color.black.opacity(0.3).blur(radius: 10))
        .offset(y: 75)
    }
}
struct CorrectCounter_Previews: PreviewProvider {
    struct CorrectCounter_Harness: View {
        @State var numCorrect = 0
        
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    CorrectCounter(numCorrect: numCorrect, action: {})
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

