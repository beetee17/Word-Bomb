//  PlayerCarouselView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 12/7/21.
//

import SwiftUI
struct PlayerCarouselView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    let spacing = CGFloat(5)
    let playerSize = Game.playerAvatarSize
    let animationDuration = 0.5
    
    var players: [Player] { viewModel.model.players.playing }
    
    var body: some View {
        
        VStack {
            ZStack {
                ForEach(players, id: \.id) { player in
                    MainPlayer(player: player,
                               chargeUpBar: true,
                               showScore: .constant(true),
                               showName: .constant(getShowName(for: player)))
                        .scaleEffect(getScale(for: player))
                        .offset(x: getOffset(for: player).x,
                                y: getOffset(for: player).y)
                        .zIndex(getZIndex(for: player))
                        .animation(.easeInOut(duration: animationDuration))
                }
            }
        }
    }
    
    private func getZIndex(for player: Player) -> Double {

        if players.isCurrent(player) {
            // current player should be above all others
            return Double(players.count)
        } else if players.isPrev(player) {
            return Double(players.count - 1)
        } else {
            return Double(players.count - player.queueNumber - 1)
        }
    }
    
    private func getShowName(for player: Player) -> Bool {
        players.isCurrent(player)
    }
    
    private func getOffset(for player: Player) -> (x: CGFloat, y: CGFloat) {
        if players.isCurrent(player) {
            return (0, 50)
        } else if players.isPrev(player) {
            return (playerSize + spacing + 18, 0)
        } else {
            return (-(playerSize + spacing + 18), 0)
        }
    }
    private func getScale(for player: Player) -> CGFloat {
        if players.isCurrent(player) {
            return 1.0
        } else if players.isNext(player) || players.isPrev(player) {
            return 0.9
        } else {
            return 0
        }
    }
}

struct PlayerCarouselView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = WordBombGameViewModel.preview(numPlayers: 3)
        VStack {
            PlayerCarouselView()
                .environmentObject(viewModel)
            Game.MainButton(label: "ANIMATE") {
                viewModel.model.process("Test",
                                        Response(status: .Correct,
                                                 score: Int.random(in: 1...10)))
            }
            Game.MainButton(label: "OUCH") {
                viewModel.model.currentPlayerRanOutOfTime()
            }
        }
    }
}
