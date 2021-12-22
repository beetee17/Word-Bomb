//
//  OutputText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI

struct OutputText: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var body: some View {
        
        
        let output = viewModel.output.trim().lowercased()
        let outputText = Text(output)
            .font(.system(size: 20, weight: .bold, design: .default))
            .textCase(.uppercase)
            .lineLimit(1)
            .transition(AnyTransition.scale.animation(.easeInOut(duration:0.3)))
            .id(output)
            .onChange(of: viewModel.output, perform: { newOutput in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                              execute: { viewModel.clearOutput(newOutput) })
            })
        
        switch output.contains("correct") {
        case true:
            outputText
                .foregroundColor(.green)
                .onAppear(perform: { Game.playSound(file: "correct") })
            
        case false:
            outputText.foregroundColor(.red)
        }
    }
}

struct OutputText_Previews: PreviewProvider {
    static var previews: some View {
        OutputText()
    }
}
