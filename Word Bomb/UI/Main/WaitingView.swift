//
//  WaitingView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct WaitingView: View, Equatable {
    static func == (lhs: WaitingView, rhs: WaitingView) -> Bool {
        lhs.props == rhs.props
    }
    
    var viewModel: WordBombGameViewModel = Game.viewModel
    
    var props: Props

    @State var animating = false
    @State var loadStatusText = "Getting Things Ready"
    
    var body: some View {

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
                
                LogoView().bounceEffect()
                
                LoadingText(text: loadStatusText)
                    .font(.bold(.subheadline)())
                
                if GameCenter.isHost {
                    Text("Players Connected: \(props.numConnectedPlayers)/\(props.numExpectedPlayers)")
                }
                Spacer()
            }
            .onChange(of: props.numConnectedPlayers) { numConnected in
                // excluding the host
                if numConnected == props.numExpectedPlayers && GameCenter.isHost {
                    // When database is large, non host are not in sync until host restarts (better to find the actual reason why)
                    GameCenter.send(GameData(allPlayersReady: true), toHost: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        viewModel.viewToShow = .Game
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

extension WaitingView {
    struct Props: Equatable {
        var numConnectedPlayers: Int
        var numExpectedPlayers: Int
    }
}

extension WordBombGameViewModel {
    var waitingViewProps: WaitingView.Props {
        .init(numConnectedPlayers: gkConnectedPlayers,
              numExpectedPlayers: model.players.queue.count - 1)
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(props: .init(numConnectedPlayers: 2, numExpectedPlayers: 3))
    }
}
