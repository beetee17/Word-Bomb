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
    let gravity: Double = 800.0
    let duration = 5.0
    
    func body(content: Content) -> some View {
                content
                    .frame(width: CGFloat.random(in: 7...12), height: CGFloat.random(in: 15...20))
                    .rotationEffect(.degrees(Double.random(in: 0...90)))
                    .foregroundColor(Color(.random))
                    .modifier(FireworkParticlesGeometryEffect(time: time, dy: dy))
                    .onAppear {
                        withAnimation (.easeOut(duration: duration)) {
                            self.time = duration
                            self.dy = gravity
                        }
                    }
            
    }
}

//struct Particle: ViewModifier {
//    @State var x_cor = Double.random(in: -40 ... 40)
//    @State var y_cor = Double.random(in: -40 ... 40)
//    @State var dx = Double.random(in: -30 ... 30)
//    @State var dy = Double.random(in: -500 ... -200)
//    let gravity: Double = 40.0
//    let duration = 5.0
//
//    func body(content: Content) -> some View {
//                content
//                    .frame(width: CGFloat.random(in: 7...12), height: CGFloat.random(in: 15...20))
//                    .rotationEffect(.degrees(Double.random(in: 0...90)))
//                    .foregroundColor(Color(.random))
//                    .modifier(FireworkParticlesGeometryEffect(x_cor: x_cor, y_cor: y_cor))
//                    .onAppear {
//                        withAnimation (.easeOut(duration: duration)) {
//                            x_cor += dx
//                            y_cor += dy
//                        }
//                    }
//                    .onChange(of: x_cor) { _ in
//                        withAnimation (.easeOut(duration: duration)) {
//
//                            // ceiling for downward acceleration
//                            dy = min(dy+gravity, 200)
//
//                            // prevent multiple updates per frame error
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
//                                x_cor += dx
//                            }
//                            y_cor += dy
//                        }
//                    }
//
//
//
//    }
//}


extension UIColor {
    static var random: UIColor {
        // gets bright colors
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
}
