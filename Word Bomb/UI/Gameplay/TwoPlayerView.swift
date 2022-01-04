//
//  TwoPlayerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 13/7/21.
//

import SwiftUI

struct TwoPlayerView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var players: [Player] { viewModel.model.players.playing }
    
    var frameWidth: CGFloat
    var leftPlayerOffset: CGFloat
    var rightPlayerOffset: CGFloat
    
    init() {
        frameWidth = Device.width*0.85
        leftPlayerOffset = -frameWidth/2 + Game.playerAvatarSize*0.75
        rightPlayerOffset = -leftPlayerOffset
    }
    
    
    var body: some View {
        
        ZStack {
            HStack(spacing: 90) {
                ForEach(players) { player in
                    ZStack {
                        MainPlayer(player: player,
                                   chargeUpBar: true,
                                   showScore: .constant(true),
                                   showName: .constant(true))
                            .scaleEffect(viewModel.model.players.current == player ? 1 : 0.9)
                            .animation(.easeInOut)
      
                    }
                }
 
            }
            
            BombView(timeLeft: $viewModel.model.controller.timeLeft, timeLimit: viewModel.model.controller.timeLimit)
                .frame(width: Game.miniBombSize,
                       height: Game.miniBombSize)
                .offset(x: getBombOffset())
                .animation(.easeInOut(duration: 0.3).delay(.PlayerTimedOut == viewModel.model.gameState ? 0.8 : 0))
                .overlay (
                    BombExplosion(animating: $viewModel.model.controller.animateExplosion)
                        .frame(width: Game.miniBombSize*1.5,
                               height: Game.miniBombSize*1.5)
                        .offset(x: getExplosionOffset(),
                                y: Game.miniBombExplosionOffset)
                )
 
        }
    }
    private func getBombOffset() -> CGFloat {
        return players.first!.queueNumber == 0
               ? leftPlayerOffset
               : rightPlayerOffset
    }
    
    private func getExplosionOffset() -> CGFloat {
        return players.first!.queueNumber == 0
               ? rightPlayerOffset + Game.miniBombExplosionOffset
               : leftPlayerOffset + Game.miniBombExplosionOffset
    }
}

struct TwoPlayerView_Previews: PreviewProvider {
    static var previews: some View {

        TwoPlayerView().environmentObject(WordBombGameViewModel())
    }
}
