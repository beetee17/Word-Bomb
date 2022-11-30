//
//  ContentView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import SwiftUI
import GameKit

struct ContentView: View {
    
    @ObservedObject var viewModel: WordBombGameViewModel = Game.viewModel
    @ObservedObject var cdViewModel: CoreDataViewModel = .shared
    
    var props: Props {
        .init(gameViewProps: viewModel.gameViewProps,
              setUpComplete: cdViewModel.setUpComplete)
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea(.all)
            
            if !props.setUpComplete {
                LoadingView()
            } else {
                GameView(props: props.gameViewProps,
                         input: $viewModel.input,
                         output: $viewModel.model.output)
                .equatable()
            }
        }
        .environmentObject(viewModel)
        .environmentObject(cdViewModel)
    }
}

extension ContentView {
    struct Props: Equatable {
        var gameViewProps: GameView.Props
        var setUpComplete: Bool
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
}


