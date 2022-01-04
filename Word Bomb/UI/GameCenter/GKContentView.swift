///
/// MIT License
///
/// Copyright (c) 2020 Sascha Müllner
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// Created by Sascha Müllner on 24.11.20.

import SwiftUI
import GameKit
import GameKitUI

struct GKContentView: View {
    @EnvironmentObject var gameViewModel: WordBombGameViewModel
    @EnvironmentObject var gkViewModel: GKMatchMakerAppModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    
    @State var showMatchMakerModal = false
    
    var body: some View {

        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(spacing:100) {
                Text("GAME CENTER").font(.largeTitle).bold()
                
                VStack(alignment: .center, spacing: 32) {
                    Game.MainButton(label: "LOGIN", systemImageName: "lock.fill") {
//                        withAnimation { gameViewModel.viewToShow = .GKLogin }
                    }
                    
                    Game.MainButton(label: "HOST MATCH", systemImageName: "person.crop.circle.badge.plus") {
                        showMatchMakerModal = true
                    }
                    .sheet(isPresented: $showMatchMakerModal) {
                        // From Apple Docs: The maximum number of players for the GKMatchType.peerToPeer, GKMatchType.hosted, and GKMatchType.turnBased types is 16.
                        GKMatchmakerView(
                            minPlayers: 2,
                            maxPlayers: 10,
                            inviteMessage: "Let us play together!"
                        ) {
                            showMatchMakerModal = false
                            
                        } failed: { (error) in
                            showMatchMakerModal = false
                            errorHandler.showBanner(title: "Match Making Failed", message: error.localizedDescription)
                        } started: { (match) in
                            showMatchMakerModal = false
                        }
                    }
                }
                
                Game.BackButton {
                    withAnimation { gameViewModel.viewToShow = .Main }
                }
            }
            
        }
        .helpButton()
        .transition(.asymmetric(insertion: AnyTransition.move(edge: .trailing), removal: AnyTransition.move(edge: .leading)))
        .animation(Game.mainAnimation)
        
    }
}

struct GKContentView_Previews: PreviewProvider {
    static var previews: some View {
        GKContentView()
    }
}
