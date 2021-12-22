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
        
        switch viewModel.viewToShow {
            
        case .main: MainView()
        case .gameTypeSelect: GameTypeSelectView()
        case .modeSelect: ModeSelectView()
        case .GKMain: GKContentView()
        case .GKLogin: AuthenticationView()
        case .game, .pauseMenu:
            ZStack {

                GamePlayView(gkMatch: gkViewModel.gkMatch)
                
                PauseMenuView()
                    .helpSheet()
                    .scaleEffect(.pauseMenu == viewModel.viewToShow ? 1 : 0.01)
                    .ignoresSafeArea(.all)
            }
        }
    }
}

//struct GameView_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        let game = WordBombGameViewModel(.game)
//        game.startGame(mode: Game.WordGame)
//        
//        return Group {
//            GameView().environmentObject(game)
//        }
//    }
//}
