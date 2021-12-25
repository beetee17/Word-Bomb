//
//  MainPlayer.swift
//  Word Bomb
//
//  Created by Brandon Thio on 25/12/21.
//

import SwiftUI

struct MainPlayer:  View {
    
    var player: Player
    @Binding var animatePlayer: Bool
    
    var body: some View {

        VStack(spacing: 5) {

            PlayerAvatar(player: player)
            if !animatePlayer {
                PlayerName(player: player)
                    .transition(.identity)
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

struct PlayerLives: View {

    var player: Player
    
    var body: some View {
        
        HStack {
            let totalLives = player.totalLives
            // redraws the hearts when player livesLeft changes
            ForEach(0..<totalLives, id: \.self) { i in
                // draws player's remaining lives filled with red
                Image(systemName: i < player.livesLeft ? "heart.fill" : "heart")
                    .resizable()
                    // smaller size depending on total number of lives to fit under avatar
                    .frame(width: totalLives > 4 ? CGFloat(68 / totalLives) : 20.0,
                           height: totalLives > 4 ? CGFloat(68 / totalLives) : 20.0,
                           alignment: .center)
                    .foregroundColor(.red)
                
            }
        }
    }
}
struct PlayerAvatar: View {
    
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

struct MainPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MainPlayer(player: Player(name: "Test"), animatePlayer: .constant(false))
    }
}
