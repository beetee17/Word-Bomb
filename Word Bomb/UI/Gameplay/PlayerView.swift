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
            switch viewModel.model.players.queue.count {
                
            case 3...Int.max:
                PlayerCarouselView()
                    .transition(.scale)
            case 2:
                TwoPlayerView()
                    .offset(x: 0, y: Device.height*0.04)
                    .transition(.scale)
            default:
                MainPlayer(player: viewModel.model.players.current, animatePlayer: .constant(false))
                    .offset(x: 0, y: Device.height*0.1)
                    .transition(.scale)
                
            }
        }
        .animation(Game.mainAnimation)
    }
}


struct PlayerView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlayerView().environmentObject(WordBombGameViewModel())
    }
}

//struct PlayerView: View {
//
//    @EnvironmentObject var viewModel: WordBombGameViewModel
//    @Binding var players: Players
//    @State var trainingMode: Bool
//
//    var body: some View {
//
//        ZStack {
//            switch viewModel.model.players.queue.count {
//
//            case 3...Int.max:
//                PlayerCarouselView()
//                    .transition(.scale)
//            case 2:
//                TwoPlayerView()
//                    .transition(.scale)
//            default:
//                if viewModel.trainingMode {
//                    HStack {
//                        Text("Lives: ").boldText()
//                        PlayerLives(player: $viewModel.model.players.current)
//                    }
//                    .offset(x: 0, y: Device.height*0.2)
//
//                } else {
//                    MainPlayer(player: viewModel.model.players.current, animatePlayer: .constant(false))
//                        .offset(x: 0, y: Device.height*0.1)
//                        .transition(.scale)
//                }
//
//            }
//        }
//        .animation(Game.mainAnimation)
//    }
//}
//
//struct PlayerView_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        Group {
//            PlayerView().environmentObject(WordBombGameViewModel.preview(numPlayers: 3))
//            PlayerView().environmentObject(WordBombGameViewModel.preview(numPlayers: 2))
//        }
//    }
//}
