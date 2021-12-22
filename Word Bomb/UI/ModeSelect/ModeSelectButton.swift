//
//  ModeSelectButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 10/7/21.
//

import SwiftUI
import GameKit
import GameKitUI

struct ModeSelectButton: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @EnvironmentObject var gkViewModel: GKMatchMakerAppModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    
    @State var showMatchMakerModal = false
    var mode: GameMode
    
    var body: some View {
        
        Button(mode.name) {
            withAnimation{
                if viewModel.gkSelect {
                    if !GKLocalPlayer.local.isAuthenticated {
                        errorHandler.showBanner(title: "Match Making Failed", message: "Login to Game Center to play online!")
                        
                    } else {
                        showMatchMakerModal.toggle()
                    }
                } else {
                    viewModel.startGame(mode: mode)
                }
            }
            
        }
        .buttonStyle(MainButtonStyle())
        .contextMenu {
            Button(action: {
                // to avoid glitchy animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7,
                                              execute: {
                    viewContext.delete(self.mode)
                    viewContext.saveObjects()
                })
            })
            {
                HStack {
                    Text("Delete \"\(mode.name.capitalized)\"")
                    Image(systemName: "trash.fill")
                }
            }
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
                viewModel.setOnlinePlayers(match.players)
                viewModel.startGame(mode: mode)
                
            }
        }
    }
    
}

//struct ModeSelectButton_Previews: PreviewProvider {
//    static var previews: some View {
//        ModeSelectButton(mode:)
//    }
//}
