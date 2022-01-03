//
//  WaitingView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct WaitingView: View {
    @State var animating = false
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @State var loadStatusText = "Getting Things Ready"
    
    var body: some View {
       
        let animation = Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)
        
        // For Game Center matches
        let numConnected = viewModel.gkConnectedPlayers
        let expectedPlayers = viewModel.model.players.queue.count - 1
        
        ZStack {
            Color("Background")
                .ignoresSafeArea(.all)
            
            VStack(spacing:50) {
                HStack {
                    GKQuitButton()
                    Spacer()
                }
                .padding(.leading, Device.width*0.05)
                .padding(.top, Device.height*0.05)
                
                Spacer()
                LogoView()
                    .offset(x: 0, y: animating ? -50 : 0)
                    .animation(animation, value: animating)
                    .onAppear() {
                        animating = true
                    }
                
                LoadingText(text: loadStatusText)
                    .font(.bold(.subheadline)())
                
                if GameCenter.isHost {
                    Text("Players Connected: \(numConnected)/\(expectedPlayers)")
                }
                Spacer()
            }
            .onChange(of: numConnected) { numConnected in
                // excluding the host
                if numConnected == expectedPlayers && GameCenter.isHost {
                    // When database is large, non host are not in sync until host restarts (better to find the actual reason why)
                    viewModel.model.restartGame()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.viewToShow = .game
                        viewModel.startTimer()
                    }
                }
            }
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 25) {
                    if GameCenter.isOnline {
                        loadStatusText = "Experiencing Network Difficulties"
                    }
                }
            }
        }
        .transition(.asymmetric(insertion: AnyTransition.move(edge: .trailing), removal: AnyTransition.move(edge: .leading)))
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
            .environmentObject(WordBombGameViewModel())
    }
}
