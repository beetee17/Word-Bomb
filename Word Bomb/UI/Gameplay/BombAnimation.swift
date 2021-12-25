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
    
    @Binding var animating: Bool
    
    var body: some View {
        
        AnimatedImage(name: "explosion-2-merge.gif", isAnimating: $animating)
            .resizable()
            .pausable(false)
            .aspectRatio(contentMode: .fill)
            .frame(width: Game.bombSize, height: Game.bombSize)
            .opacity(animating ? 1 : 0)
            .onChange(of: animating) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + Game.explosionDuration) {
                    animating = false
                    print("FALSE AGAIN")
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
                Button("Animate!") {
                    animating.toggle()
                }
            }
        }
    }
    
    static var previews: some View {
        BombExplosion_Harness()
    }
}
