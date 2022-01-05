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
            action()
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
    var isShowing: Bool
    var addLifeAction: () -> Void
    var addTimeAction: () -> Void
    
    var body: some View {
        if isShowing {
            VStack(spacing: 20) {
                
                Button(action: addLifeAction) {
                    Image(systemName: "heart.fill")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.red)
                        .shadow(color: .green.opacity(0.5), radius: 3)
                        .pulseEffect()
                }
                .buttonStyle(ScaleEffect())
                .onTapGesture { AudioPlayer.playSound(.Combo) }
                
                Button(action: addTimeAction) {
                    Image(systemName: "stopwatch")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .shadow(color: .green.opacity(0.7), radius: 3)
                        .pulseEffect()
                        
                }
                .buttonStyle(ScaleEffect())
                .onTapGesture { AudioPlayer.playSound(.Combo) }
                
            }
            .background(Color.black.opacity(0.3).blur(radius: 10))
            .offset(y: 75)
            .transition(.offset(y: -75).combined(with: .opacity))
        }
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
                    
                    ZStack {
                        CorrectCounter(numCorrect: numCorrect, action: { withAnimation(.easeInOut) { showReward.toggle() } })
                        RewardOptions(isShowing: showReward, addLifeAction: {}, addTimeAction: {})
                        
                    }
                    
                    //                    Game.MainButton(label: "Plus One") {
                    //                        numCorrect += 1
                    //                    }
                    //                    Game.MainButton(label: "Times Ten") {
                    //                        numCorrect *= 10
                    //                    }
                }
            }
        }
    }
    static var previews: some View {
        CorrectCounter_Harness()
    }
}

