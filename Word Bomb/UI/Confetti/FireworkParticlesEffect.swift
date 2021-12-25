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



