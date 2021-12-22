//
//  InputView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI
import GameKit

struct InputView: View {
    
    // Presented when game is ongoing for user to see query and input an answer
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @State var commitInput = false
    var gkMatch: GKMatch?
    
    var body: some View {
        
        ZStack {
            PermanentKeyboard(text: $viewModel.input, forceResignFirstResponder: $viewModel.forceHideKeyboard)
            Text(viewModel.input)
                .onChange(of: viewModel.input,
                          perform: { _ in if viewModel.input.last == "\n" {
                            
                            viewModel.processInput()
                                
                            
                            viewModel.input = ""
                          }
                          }).ignoresSafeArea(.keyboard)
                
                .font(Font.system(size: 20))
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
    }
}
