//
//  TimerView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 24/7/21.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    var body: some View {
        if viewModel.playerQueue.count > 2 {
            ZStack {
                BombView()
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(String(format: "%.1f", viewModel.timeLeft))
                            .offset(x: 5, y: 10))
                
                
                BombExplosion()
                    .offset(x: 10, y: 10)
                // to center explosion on bomb
            }
        }
        
        else {
            Text(String(format: "%.1f", viewModel.timeLeft))
                .font(.largeTitle)
        }
    }
}


struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}
