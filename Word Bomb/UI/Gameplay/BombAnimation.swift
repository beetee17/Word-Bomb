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
        // Do not somehow exceed the maximum frame number
        let frameNumber =
            min(25,
                numTotalFrames - safeDivideByZero(timeLimit, by: timeLimit/Float(numTotalFrames)) + 1)
        
        if frameNumber >= 10 {
            
            return String(format: "frame_apngframe%02d", frameNumber)
        }
        else {
            return String(format: "frame_apngframe%02d", frameNumber)
        }
    }
    private func safeDivideByZero(_ dividend: Float, by divisor: Float) -> Int {
        guard divisor.isFinite && dividend.isFinite && divisor != 0 else { return 0 }
        return Int(dividend/divisor)
    }
}




struct BombExplosion: View {
    
    @Binding var animating: Bool
    
    var body: some View {
        
        AnimatedImage(name: "explosion-2-merge.gif", isAnimating: $animating)
            .resizable()
            .pausable(false)
            .aspectRatio(contentMode: .fill)
            .frame(width: Game.bombSize, height: Game.bombSize)
            .opacity(animating ? 1 : 0)
            .onChange(of: animating) { output in
                DispatchQueue.main.asyncAfter(deadline: .now() + Game.explosionDuration) {
                    if output {
                        animating = false
                        print("FALSE AGAIN")
                    }
                }
            }
    }
}



struct BombView_Preview: PreviewProvider {
    
    struct BombView_Harness: View {
        
        @State private var timeLeft: Float = 10
        @State private var timeLimit: Float = 10
        
        var body: some View {
            BombView(timeLeft: $timeLeft, timeLimit: timeLimit)
        }
    }
    
    static var previews: some View {
        BombView_Harness()
    }
}

struct BombExplosion_Preview: PreviewProvider {
    
    struct BombExplosion_Harness: View {
        
        @State private var animating = false
        
        var body: some View {
            VStack {
                BombExplosion(animating: $animating)
                Button(animating ? "Animating" : "Animate!") {
                    animating = true
                }
            }
        }
    }
    
    static var previews: some View {
        BombExplosion_Harness()
    }
}
