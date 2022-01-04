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

struct GameView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @EnvironmentObject var gkViewModel: GKMatchMakerAppModel
    
    var body: some View {
        ZStack {
            switch viewModel.viewToShow {
                
            case .Main: MainView()
            case .GameTypeSelect:
                GameTypeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .ModeSelect:
                ModeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .Waiting: WaitingView()
            case .Game, .PauseMenu:
                ZStack {
                    
                    GamePlayView(gkMatch: gkViewModel.gkMatch)
                    
                }
            }
        }
        .if(viewModel.viewToShow != .Game) { $0.helpButton() }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(WordBombGameViewModel.preview())
            .environmentObject(GKMatchMakerAppModel())
    }
}
