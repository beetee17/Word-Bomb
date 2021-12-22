//
//  BombAnimation.swift
//  Word Bomb
//
//  Created by Brandon Thio on 16/7/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct BombView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel

    var body: some View {
        
        Image(updateFrame(numTotalFrames: 24, timeLeft: viewModel.timeLeft, timeLimit: viewModel.timeLimit))
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
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {

        AnimatedImage(name: "explosion-2-merge.gif", isAnimating: $viewModel.animateExplosion)
            .resizable()
            .pausable(false)
            .aspectRatio(contentMode: .fill)
            .frame(width: Game.bombSize, height: Game.bombSize)
            .opacity(viewModel.animateExplosion ? 1 : 0)
            .onChange(of: viewModel.animateExplosion) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + Game.explosionDuration) {
                    viewModel.animateExplosion = false
                }
            }
            
            
    }
}




//struct BombView: PreviewProvider {
//    static var previews: some View {
//        BombAnimation()
//    }
//}
