//
//  ContentView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import SwiftUI
import GameKit

struct ContentView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @EnvironmentObject var coreDataVM: CoreDataViewModel
    
    var body: some View {
        ZStack {

            Color("Background")
                .ignoresSafeArea(.all)
            
            if !coreDataVM.setUpComplete {
                LoadingView()
            } else {
                GameView()
            }
        }
    }
}






struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {

       ContentView()
            .environmentObject(WordBombGameViewModel())
    }
}


