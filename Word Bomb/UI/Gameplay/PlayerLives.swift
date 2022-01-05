//
//  PlayerLives.swift
//  Word Bomb
//
//  Created by Brandon Thio on 31/12/21.
//

import SwiftUI

struct PlayerLives: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var player: Player
    
    var body: some View {
        
        HStack {
            let totalLives = player.totalLives
            
            // redraws the hearts when player livesLeft changes
            ForEach(1...totalLives, id: \.self) { i in
                // draws player's remaining lives filled with red
                PlayerLive(size: totalLives > 4 ? CGFloat(68 / totalLives) : 20.0, animate: Binding(
                    get: { i > player.livesLeft },
                    set: { _ in  }
                ))
            }
        }
    }
}
struct Shake: GeometryEffect {
    var amount: CGFloat = 20
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
struct PlayerLive: View {
    var size: CGFloat
    @Binding var animate: Bool
    
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .resizable()
                .frame(width: size,
                       height: size,
                       alignment: .center)
                .foregroundColor(.red)
                .scaleEffect(animate ? 0 : 1)
                .opacity(animate ? 0 : 1)
                .modifier(Shake(animatableData: CGFloat(1)))
            
            Image(systemName: "heart")
                .resizable()
                .frame(width: size,
                       height: size,
                       alignment: .center)
                .foregroundColor(.red)
                .modifier(Shake(animatableData: CGFloat(animate ? 1 : 0)))
        }
    }
}

struct PlayerLive_Previews: PreviewProvider {
    struct PlayerLive_Harness: View {
        @State var animate = false
        var body: some View {
            VStack {
            PlayerLive(size: CGFloat(20), animate: $animate)
                Game.MainButton(label: "ANIMATE") {
                    animate.toggle()
                }
            }
        }
    }
    static var previews: some View {
        PlayerLive_Harness()
    }
}

struct PlayerLives_Previews: PreviewProvider {
    struct PlayerLives_Harness: View {
        
        var body: some View {
            let viewModel = WordBombGameViewModel.preview(numPlayers: 1)
            VStack {
                PlayerLives(player: viewModel.model.players.current)
                    .environmentObject(viewModel)
                
                Game.MainButton(label: "OUCH") {
                    viewModel.model.currentPlayerRanOutOfTime()
                }
                Game.MainButton(label: "RESET") {
                    viewModel.model.players.reset()
                }
            }
        }
    }
    static var previews: some View {
        PlayerLives_Harness()
    }
}
