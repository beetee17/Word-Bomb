//
//  PlayerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI


struct PlayerView: View {
    // Appears in game scene to display current player's name
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {
        
        ZStack {
            switch viewModel.playerQueue.count {
                
            case 3...Int.max:
                PlayerCarouselView()
                    .transition(.scale)
            case 2:
                TwoPlayerView()
                    .offset(x: 0, y: 50)
                    .transition(.scale)
            default:
                MainPlayer(player: viewModel.currentPlayer, animatePlayer: .constant(false))
                    .offset(x: 0, y: 50)
                    .transition(.scale)
                    
            }
        }
        .animation(Game.mainAnimation)
    }
}

struct PlayerName: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        switch .gameOver == viewModel.gameState && viewModel.currentPlayer.name == player.name {
        case true:
            
            Text("\(player.name) WINS!")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .lineLimit(1).minimumScaleFactor(0.5)
        case false:
            
            Text("\(player.name)")
                .font(.largeTitle)
                .lineLimit(1).minimumScaleFactor(0.5)
        }
    }
}

struct PlayerLives: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        
        HStack {
            
            // redraws the hearts when player livesLeft changes
            // smaller size depending on total number of lives to fit under avatar
            
            ForEach(0..<player.livesLeft, id: \.self) { i in
                // draws remaining lives filled with red
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: viewModel.livesLeft > 4 ? CGFloat(68 / viewModel.livesLeft) : 20.0,
                           height: viewModel.livesLeft > 4 ? CGFloat(68 / viewModel.livesLeft) : 20.0,
                           alignment: .center)
                    .foregroundColor(.red)
                
            }
            
            ForEach(0..<max(0, viewModel.livesLeft - player.livesLeft), id: \.self) { i in
                // draws lives lost (if any) unfilled
                Image(systemName: "heart")
                    .resizable()
                    .frame(width: viewModel.livesLeft > 4 ? CGFloat(68 / viewModel.livesLeft) : 20.0,
                           height: viewModel.livesLeft > 4 ? CGFloat(68 / viewModel.livesLeft) : 20.0,
                           alignment: .center)
                    .foregroundColor(.red)
                
            }
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
struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlayerView().environmentObject(WordBombGameViewModel())
    }
}
