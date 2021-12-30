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
    var xSpeed = Double.random(in: 50 ... 150)
    var ySpeed = Double.random(in: 1200 ... 1700)
    var direction = Double.random(in: -0.8*Double.pi ...  -0.3*Double.pi)
    
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(Double(time), Double(dy)) }
        set {
            time = newValue.first
            dy = newValue.second
        }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = xSpeed * cos(direction) * time
        let yTranslation = ySpeed * sin(direction) * time + time*dy
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}



