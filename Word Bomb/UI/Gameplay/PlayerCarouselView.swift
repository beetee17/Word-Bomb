//  PlayerCarouselView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 12/7/21.
//

import SwiftUI

struct PlayerCarouselView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @State var animatePlayers = false

    var body: some View {
        let currentPlayer = viewModel.playerQueue[0]
        let nextPlayer = viewModel.playerQueue[1]
        let prevPlayer = viewModel.playerQueue[back: 0]
        
        let playerSize = Game.playerAvatarSize
        let spacing = CGFloat(5.0)

        HStack(spacing: spacing) {

            ZStack {

                LeftPlayer(player: animatePlayers ? currentPlayer : nextPlayer, animatePlayer: $animatePlayers)
                    .offset(x: animatePlayers ? playerSize + spacing : 0, y: animatePlayers ? 50 : 0)
                    .scaleEffect(animatePlayers ? 1 : 0.9)
                    .zIndex(2)

                LeftPlayer(player: nextPlayer, animatePlayer: .constant(false))
                    .scaleEffect(animatePlayers ? 0.9 : 0.01)
                    .zIndex(0)

            }


            MainPlayer(player: animatePlayers ? prevPlayer : currentPlayer, animatePlayer: $animatePlayers)
                .offset(x: animatePlayers ? (1/0.9)*playerSize + spacing : 0, y: animatePlayers ? 0 : 50)
                .scaleEffect(animatePlayers ? 0.9 : 1)
                .zIndex(animatePlayers ? 1 : 2)

            ZStack {

                RightPlayer(player: animatePlayers ? viewModel.playerQueue[back: 1] : prevPlayer)
                    .scaleEffect(animatePlayers ? 0.01 : 0.9)

            }
        }
        .animation(animatePlayers ? .easeInOut(duration: 0.3) : nil)

        .onChange(of: viewModel.playerQueue, perform: { _ in

            withAnimation { animatePlayers.toggle() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { animatePlayers = false })

        })

    }
}

struct LeftPlayer: View {
    var player: Player
    @Binding var animatePlayer: Bool

    var body: some View {

        VStack(spacing: 5) {

            PlayerAvatar(player: player)
            if animatePlayer {
                PlayerName(player: player)
                    .transition(.identity)

            }
            PlayerLives(player: player)

        }
    }
}


struct RightPlayer: View {
    var player: Player

    var body: some View {

        VStack(spacing: 5) {

            PlayerAvatar(player: player)
            PlayerLives(player: player)

        }
    }
}

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
struct PlayerCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerCarouselView().environmentObject(WordBombGameViewModel())
    }
}
