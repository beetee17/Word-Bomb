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
                    ChargeUpBar(value: viewModel.model.players.current.chargeProgress,
                                invert: false)
                        .frame(height: 40)
                    
                    MainPlayer(player: viewModel.model.players.current,
                               chargeUpBar: false,
                               showScore: .constant(true),
                               showName: .constant(true))
                        .transition(.scale)
                }
                .onChange(of: viewModel.model.players.current) { new in
                    print("CURREnt CHANGE TO \(new.name)")
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
