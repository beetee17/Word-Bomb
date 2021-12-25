//
//  BombAnimation.swift
//  Word Bomb
//
//  Created by Brandon Thio on 16/7/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct BombView: View {
    
    @Binding var timeLeft: Float
    @State var timeLimit: Float
    
    var body: some View {
        
        Image(updateFrame(numTotalFrames: 24, timeLeft: timeLeft, timeLimit: timeLimit))
            .resizable()
            .scaledToFit()
  
    }
    
    private func updateFrame(numTotalFrames: Int, timeLeft: Float, timeLimit: Float) -> String {
        let frameNumber = numTotalFrames - Int(timeLeft / (timeLimit / Float(numTotalFrames))) + 1
        
        if frameNumber >= 10 {
            
            return String(format: "frame_apngframe%02d", frameNumber)
        }
        else {
            return String(format: "frame_apngframe%02d", frameNumber)
        }
    }
        
}




struct BombExplosion: View {
    
    @State var animateExplosion = false
    @Binding var gameState: GameState
    
    var body: some View {
        
        AnimatedImage(name: "explosion-2-merge.gif", isAnimating: $animateExplosion)
            .resizable()
            .pausable(false)
            .aspectRatio(contentMode: .fill)
            .frame(width: Game.bombSize, height: Game.bombSize)
            .opacity(animateExplosion ? 1 : 0)
            .onChange(of: gameState) { _ in
                if gameState == .playerTimedOut || gameState == .gameOver {
                    animateExplosion = true
                    Game.playSound(file: "explosion")
                    DispatchQueue.main.asyncAfter(deadline: .now() + Game.explosionDuration) {
                        animateExplosion = false
                    }
                }
            }
    }
}




//struct BombView: PreviewProvider {
//    static var previews: some View {
//        BombAnimation()
//    }
//}
