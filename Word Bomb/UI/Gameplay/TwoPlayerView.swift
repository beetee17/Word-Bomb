//
//  TwoPlayerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 13/7/21.
//

import SwiftUI

struct TwoPlayerView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {

        let frameWidth = Device.width*0.85
        
        ZStack {
            HStack(spacing: 90) {
                ForEach(viewModel.model.players.queue) { player in
                    ZStack {
                        MainPlayer(player: player, animatePlayer: .constant(false))
                            .scaleEffect(viewModel.model.players.current == player ? 1 : 0.9)
                            .animation(.easeInOut)
      
                    }
                }
 
            }
            .frame(minWidth: frameWidth, maxWidth: frameWidth, minHeight: 0, alignment: .top)
            
            let leftPlayerOffset = -frameWidth/2 + Game.playerAvatarSize*0.75
            let rightPlayerOffset = -leftPlayerOffset
            
            BombView(timeLeft: $viewModel.model.timeKeeper.timeLeft, timeLimit: viewModel.model.timeKeeper.timeLimit)
                .frame(width: Game.miniBombSize,
                       height: Game.miniBombSize)
                .offset(x: viewModel.model.players.current == viewModel.model.players.queue[0] ? leftPlayerOffset : rightPlayerOffset,
                        y: 0)
                .animation(.easeInOut(duration: 0.3).delay(.playerTimedOut == viewModel.model.gameState ? 0.8 : 0))
                .overlay (
                    BombExplosion(animating: $viewModel.model.media.animateExplosion)
                        .frame(width: Game.miniBombSize*1.5,
                               height: Game.miniBombSize*1.5)
                        .offset(x: viewModel.model.players.current == viewModel.model.players.queue[0] ? rightPlayerOffset + Game.miniBombExplosionOffset : leftPlayerOffset + Game.miniBombExplosionOffset,
                                y: Game.miniBombExplosionOffset)
                )
 
        }
    }
}

struct TwoPlayerView_Previews: PreviewProvider {
    static var previews: some View {

        TwoPlayerView().environmentObject(WordBombGameViewModel())
    }
}
