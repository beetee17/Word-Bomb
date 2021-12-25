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
    @State var pauseMenu = false
    
    
    var body: some View {
        ZStack {
            switch viewModel.viewToShow {
                
            case .main: MainView()
            case .gameTypeSelect:
                GameTypeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .modeSelect:
                ModeSelectView(gameType: $viewModel.gameType, viewToShow: $viewModel.viewToShow)
            case .GKMain: GKContentView()
            case .GKLogin: AuthenticationView()
            case .game, .pauseMenu:
                ZStack {
                    
                    GamePlayView(gkMatch: gkViewModel.gkMatch)
                    
                    PauseMenuView()
                        .helpButton()
                        .scaleEffect(viewModel.viewToShow == .pauseMenu ? 1 : 0.01)
                        .ignoresSafeArea(.all)
                }
            }
        }
        .if(![.game, .pauseMenu].contains(viewModel.viewToShow)) { $0.helpButton() }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environmentObject(WordBombGameViewModel.preview())
            .environmentObject(GKMatchMakerAppModel())
    }
}
