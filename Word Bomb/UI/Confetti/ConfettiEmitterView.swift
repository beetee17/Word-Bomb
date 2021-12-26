//
//  ConfettiEmitterView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 26/12/21.
//

import SwiftUI

struct Confetti: View {
    var body: some View {
        ZStack {
            ConfettiEmitterView()
        }
    }
}
struct ConfettiEmitterView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterShape = .line
        emitterLayer.emitterCells = createEmitterCells()
        emitterLayer.emitterSize = CGSize(width: Device.width, height: 1)
        emitterLayer.emitterPosition = CGPoint(x: Device.width / 2, y: Device.height/2)
        
        view.layer.addSublayer(emitterLayer)
        
        return view
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    func createEmitterCells() -> [CAEmitterCell] {
        let cell = CAEmitterCell()
        
        cell.contents = UIImage(named: "bomb-icon")?.cgImage
        //        cell.color = UIColor.white.cgColor
        //        cell.birthRate = 15
        //        cell.lifetimeRange = 20
        //        cell.velocity = -1000
        //        cell.velocityRange = 0.5
        //        cell.scale = 0.1
        //        cell.yAcceleration = 500
        //        cell.emissionLongitude = .pi
        //        cell.emissionRange = 0.1
        
        /* -pi/2 = up  */
        cell.emissionLongitude = 0
        cell.emissionLatitude = 0
        cell.emissionRange = .pi*2
        cell.lifetime = 1.6
        cell.birthRate = 10
        
        /*
         * @note velocity - determines the speed of the particle, the higher the volicity
         * the further it travels on the screen. This is effected by yAcceleration
         *
         * @note yAcceleration - simulates gravity
         * a postive value applys gravity while negative value simulates a
         * lack or reduction of gravity allowing particles to "fly".
         * the combination of velocity & yAcceleration determines distance
         */
        cell.velocity = 400
        cell.velocityRange = cell.velocity*2
        cell.yAcceleration = 50
        cell.scale = 0.1
        
        return [cell]
    }
}

struct ConfettiEmitterView_Previews: PreviewProvider {
    static var previews: some View {
        Confetti()
    }
}
