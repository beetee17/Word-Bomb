//
//  PlayerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI

struct PlayerView: View {
    
    // Appears in game scene to display current player's name
    var viewModel = Game.viewModel
    var props: Props
    
    var body: some View {
        print("Redrawing PlayerView")
        return ZStack {
            switch props.players.playing.count {
                
            case 3...Int.max:
                PlayerCarouselView()
                    .offset(y: -Device.height*0.012)
                    .transition(.scale)
            case 2:
                TwoPlayerView()
                    .offset(y: Device.height*0.02)
                    .transition(.scale)
            default:
                SinglePlayer(player: props.players.current, props: props)
            }
        }
        .animation(Game.mainAnimation)
    }
}

struct SinglePlayer: View {
    var viewModel = Game.viewModel
    
    @ObservedObject var player: Player
    
    var props: PlayerView.Props
    
    var body: some View {
        VStack {
            let player = props.players.current
            ChargeUpBar(imagePicker: StarImagePicker(),
                        value: player.chargeProgress,
                        multiplier: player.multiplier,
                        invert: false)
                .frame(height: Device.height*0.035)
                .padding(.horizontal)
            
            MainPlayer(player: player,
                       chargeUpBar: false,
                       showScore: .constant(true),
                       showName: .constant(false),
                       showLives: props.frenzyMode ? .constant(false) : .constant(true))
                .transition(.scale)
                .if(props.arcadeMode || props.frenzyMode) {
                    $0.overlay(
                        GoldenTickets(numTickets: player.numTickets,
                                      claimAction: { viewModel.claimReward(of: .FreePass) } )
                            .offset(y: -(Game.playerAvatarSize/3.5))
                            
                    )}
        }
        .padding(.top, 5)
    }
}

extension PlayerView {
    struct Props: Equatable {
        var players: Players
        var frenzyMode: Bool
        var arcadeMode: Bool
    }
}

extension WordBombGameViewModel {
    var playerViewProps: PlayerView.Props {
        .init(players: model.players, frenzyMode: frenzyMode, arcadeMode: arcadeMode)
    }
}

struct PlayerView_Previews: PreviewProvider {

    static var previews: some View {
        let threePlayerVm = WordBombGameViewModel.preview(numPlayers: 3)
        let twoPlayerVm = WordBombGameViewModel.preview(numPlayers: 2)
        Group {
            PlayerView(props: threePlayerVm.playerViewProps)
                .environmentObject(threePlayerVm)
            PlayerView(props: twoPlayerVm.playerViewProps)
                .environmentObject(twoPlayerVm)
        }
    }
}
