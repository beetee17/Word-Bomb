//
//  GameView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI
import CoreData
import GameKit
import GameKitUI

struct GameView: View, Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.props == rhs.props &&
        lhs.input == rhs.input &&
        lhs.output == rhs.output
    }
    
    var viewModel: WordBombGameViewModel = Game.viewModel
    
    var props: Props
    
    @Binding var input: String
    @Binding var output: String
    
    @State var showAds: Bool = true
    
    var body: some View {
        print("Redrawing GameView")
        return ZStack {
            switch props.viewToShow {
                
            case .Main:
                MainView()
            case .GameTypeSelect:
                EmptyView()
            case .ModeSelect:
                EmptyView()
            case .Waiting:
                WaitingView(props: props.waitingViewProps)
                    .equatable()
            case .Game:
                GamePlayView(props: props.gamePlayViewProps,
                             input: $input,
                             output: $output)
                .equatable()
            }
        }
        .if(props.viewToShow != .Game) { $0.helpButton(action: MainViewVM.shared.dismissTutorial) }
    }
}

extension GameView {
    struct Props: Equatable {
        var gamePlayViewProps: GamePlayView.Props
        var waitingViewProps: WaitingView.Props
        var viewToShow: ViewToShow
    }
}

extension WordBombGameViewModel {
    var gameViewProps: GameView.Props {
        .init(gamePlayViewProps: gamePlayViewProps,
              waitingViewProps: waitingViewProps,
              viewToShow: viewToShow)
    }
}

//struct GameView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameView()
//            .environmentObject(WordBombGameViewModel.preview())
//            .environmentObject(GKMatchMakerAppModel())
//    }
//}
