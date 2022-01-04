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
            switch viewModel.model.players.playing.count {
                
            case 3...Int.max:
                PlayerCarouselView()
                    .transition(.scale)
            case 2:
                TwoPlayerView()
                    .offset(x: 0, y: Device.height*0.07)
                    .transition(.scale)
            default:
                
                VStack {
                    let player = viewModel.model.players.current
                    ChargeUpBar(imagePicker: StarImagePicker(),
                                value: player.chargeProgress,
                                multiplier: player.multiplier,
                                invert: false)
                        .frame(height: 40)
                        .padding(.horizontal)
                    
                    MainPlayer(player: viewModel.model.players.current,
                               chargeUpBar: false,
                               showScore: .constant(true),
                               showName: .constant(true))
                        .transition(.scale)
                }
                .padding(.top, 20)
                
            }
        }
        .animation(Game.mainAnimation)
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
