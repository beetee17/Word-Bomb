//
//  ConfettiView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//  From https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b

import SwiftUI
import simd

struct ConfettiView: View {
    var body: some View {
        ZStack {
            ForEach(1...100, id: \.self) { index in
            Rectangle()
                .modifier(Particle())
                .offset(x: 0, y: Device.height*0.8)
            }
        }
        .onAppear() {
            Game.playSound(file: "confetti")
        }
    }
}
struct ConfettiView_Previews: PreviewProvider {
    
    struct ConfettiView_Harness: View {
        
        @State var animate = false
        
        var body: some View {
            ZStack {
                Button(animate ? "ANIMATION COMPLETE" : "ANIMATE") {
                    animate.toggle()
                }
                if animate {
                    ConfettiView()
                }
                
            }
        }
    }
    static var previews: some View {
        ConfettiView_Harness()
    }
}

