//
//  ConfettiModifier.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//
//  From https://betterprogramming.pub/creating-confetti-particle-effects-using-swiftui-afda4240de6b

import Foundation
import SwiftUI

struct Particle: ViewModifier {
    @State var time = 0.0
    @State var dy = 0.0
    @State var opacity = 1.0
    let gravity: Double = 800.0
    let duration = 5.0
    
    func body(content: Content) -> some View {
                content
                    .frame(width: CGFloat.random(in: 7...12), height: CGFloat.random(in: 15...20))
                    .rotationEffect(.degrees(Double.random(in: 0...90)))
                    .foregroundColor(Color(.random))
                    .modifier(FireworkParticlesGeometryEffect(time: time, dy: dy))
                    .opacity(opacity)
                    .onAppear {
                        withAnimation (.easeOut(duration: duration)) {
                            self.time = duration
                            self.dy = gravity
                            
                        }
                        withAnimation(.easeInOut(duration: duration)) {
                            self.opacity = 0
                        }
                    }
            
    }
}

extension UIColor {
    static var random: UIColor {
        // gets bright colors
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
}
