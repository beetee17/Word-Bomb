//
//  ConfettiModifier.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//
//  From https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b

import Foundation
import SwiftUI

struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.1
    let duration = 5.0
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<100, id: \.self) { index in
                content
                    .frame(width: CGFloat.random(in: 7...12), height: CGFloat.random(in: 15...20))
                    .rotationEffect(.degrees(Double.random(in: 0...90)))
                    .hueRotation(Angle(degrees: time * 100))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration-time) / duration))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration)) {
                self.time = duration
                self.scale = 1.0
            }
        }
    }
}
