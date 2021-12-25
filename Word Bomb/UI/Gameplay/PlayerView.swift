//
//  PlayerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI


struct PlayerView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var body: some View {
        
        ZStack {
            switch viewModel.model.players.queue.count {
                
            case 3...Int.max:
                PlayerCarouselView()
                    .transition(.scale)
            case 2:
                TwoPlayerView()
                    .transition(.scale)
            default:
                if viewModel.trainingMode {
                    HStack {
                        Text("Lives: ").boldText()
                        PlayerLives(player: viewModel.model.players.current)
                    }
                    .offset(x: 0, y: Device.height*0.2)
                    
                } else {
                    MainPlayer(player: viewModel.model.players.current, animatePlayer: .constant(false))
                        .offset(x: 0, y: Device.height*0.1)
                        .transition(.scale)
                }
                
            }
        }
        .animation(Game.mainAnimation)
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
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        
        HStack {
            let totalLives = viewModel.model.totalLives
            
            // redraws the hearts when player livesLeft changes
            ForEach(0..<viewModel.model.totalLives, id: \.self) { i in
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
struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            PlayerView().environmentObject(WordBombGameViewModel.preview(numPlayers: 3))
            PlayerView().environmentObject(WordBombGameViewModel.preview(numPlayers: 2))
        }
    }
}
