//
//  MainPlayer.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI

struct MainPlayer:  View {
    var player: Player
    var chargeUpBar: Bool
    @Binding var showScore: Bool
    @Binding var showName: Bool
    
    
    var body: some View {

        VStack(spacing: 5) {
            if showScore {
                ScoreCounter(score: player.score)
            }
            HStack(alignment:.center) {
                
                if chargeUpBar {
                    ChargeUpBar(value: player.chargeProgress,
                                invert: true)
                        .frame(width: 10, height: 100)
                }
                
                PlayerAvatar(player: player)
            }
            if showName {
                PlayerName(player: player)
                    .transition(.scale)
            }
            
            PlayerLives(player: player)
            
            
        }
    }
}

struct PlayerName: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        if viewModel.model.gameState == .gameOver && viewModel.model.players.current == player && !viewModel.trainingMode {
        
            Text("\(player.name) WINS!")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .lineLimit(1).minimumScaleFactor(0.5)
        } else {
            
            Text("\(player.name)")
                .font(.largeTitle)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
    }
}



struct PlayerAvatar: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {

        if let avatar = player.image {
            Image(uiImage: UIImage(data: avatar)!)
                .resizable()
                .frame(width: Game.playerAvatarSize, height: Game.playerAvatarSize, alignment: .center)
                .clipShape(Circle())
        }
        else {
            let text = String(player.name.first?.uppercased() ?? "")
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: Game.playerAvatarSize, height: Game.playerAvatarSize, alignment: .center)
                .foregroundColor(.gray)
                .overlay(Text(text)
                            .font(.system(size: 60,
                                          weight: .regular,
                                          design: .rounded))
                            )
        }
            
    }
}

//struct MainPlayer_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let viewModel = WordBombGameViewModel.preview(numPlayers: 1)
//        
//        VStack {
//            MainPlayer(
//                player: viewModel.model.players.current,
//                animatePlayer: .constant(false)
//            ).environmentObject(viewModel)
//            
//            Game.MainButton(label: "OUCH") {
//                viewModel.model.currentPlayerRanOutOfTime()
//            }
//            Game.MainButton(label: "RESET") {
//                viewModel.model.players.reset()
//            }
//        }
//    }
//}
