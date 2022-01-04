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
    @StateObject var imagePicker = StarImagePicker()
    
    var body: some View {
        
        VStack(spacing: 5) {
            if showScore {
                ScoreCounter(score: player.score,
                             imagePicker: imagePicker)
            }
            
            PlayerAvatar(player: player)
                .if(chargeUpBar) {
                    $0.overlay(
                        ChargeUpBar(imagePicker: imagePicker,
                                    value: player.chargeProgress,
                                    multiplier: player.multiplier,
                                    invert: true)
                            .frame(width: 10, height: Device.height*0.12)
                            .offset(x: -(Game.playerAvatarSize/2 + 10))
                    )}

            if showName {
                PlayerName(player: player)
            }
            
            PlayerLives(player: player)
                .onChange(of: player.livesLeft) { _ in
                    imagePicker.getImage(for: .Sad)
                }
            
        }
    }
}

struct PlayerName: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        if viewModel.model.gameState == .GameOver && viewModel.model.players.current == player && !viewModel.trainingMode {
            
            Text("\(player.name) WINS!")
                .font(.title)
                .lineLimit(1).minimumScaleFactor(0.5)
        } else {
            
            Text("\(player.name)")
                .font(.title)
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
                            .font(.system(size: 50,
                                          weight: .regular,
                                          design: .rounded))
                )
        }
        
    }
}

struct MainPlayer_Previews: PreviewProvider {

    static var previews: some View {
        let viewModel = WordBombGameViewModel.preview(numPlayers: 1)
        
        VStack {
            MainPlayer(player: viewModel.model.players.current,
                       chargeUpBar: true,
                       showScore: .constant(true),
                       showName: .constant(true)
            ).environmentObject(viewModel)
            
            Game.MainButton(label: "YAY") {
                viewModel.model.process("TEST",
                                        Response(status: .Correct, score: 10))
            }
            
            Game.MainButton(label: "OUCH") {
                viewModel.model.currentPlayerRanOutOfTime()
            }
            
        }
    }
}
