//
//  ConfettiView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//  From https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b

import SwiftUI

struct ConfettiView: View {
    var body: some View {
        ZStack {
            
            Rectangle()
                .modifier(ParticlesModifier())
                .offset(x: -100, y : -50)
            
            Rectangle()
                .modifier(ParticlesModifier())
                .offset(x: 60, y : 70)
        }
        .onAppear() {
            Game.playSound(file: "confetti")
        }
    }
}
struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView()
    }
}
