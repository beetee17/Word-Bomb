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
                
            case .main: MainView()
            case .gameTypeSelect:
                GameTypeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .modeSelect:
                ModeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .waiting: WaitingView()
            case .game, .pauseMenu:
                ZStack {
                    
                    GamePlayView(gkMatch: gkViewModel.gkMatch)
                    
                }
            }
        }
        .if(viewModel.viewToShow != .game) { $0.helpButton() }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(WordBombGameViewModel.preview())
            .environmentObject(GKMatchMakerAppModel())
    }
}
