//
//  FireworkParticlesEffect.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI
struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var dy: Double
    var speed = Double.random(in: 500 ... 1200)
    var direction = Double.random(in: -0.6*Double.pi ...  -0.4*Double.pi)
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(Double(time), Double(dy)) }
        set {
            time = newValue.first
            dy = newValue.second
        }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time + time*dy
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}
//struct FireworkParticlesGeometryEffect : GeometryEffect {
//
//    var x_cor: Double
//    var y_cor: Double
//
//    var animatableData: AnimatablePair<Double, Double> {
//        get { AnimatablePair(Double(x_cor), Double(y_cor)) }
//        set {
//            x_cor = newValue.first
//            y_cor = newValue.second
//        }
//    }
//
//    func effectValue(size: CGSize) -> ProjectionTransform {
//
//        let affineTranslation =  CGAffineTransform(translationX: x_cor, y: y_cor)
//        return ProjectionTransform(affineTranslation)
//    }
//}


