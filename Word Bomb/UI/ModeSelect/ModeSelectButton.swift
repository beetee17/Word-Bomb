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
    
    @State var showMatchMakerModal = false
    var mode: GameMode
    
    func deleteMode() {
        // to avoid glitchy animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7,
                                      execute: {
            guard !mode.isDefault_ else {
                Game.errorHandler.showBanner(title: "Deletion Prohibited", message: "Cannot delete a default game mode!")
                return
            }
            viewContext.delete(self.mode)
            viewContext.saveObjects()
            AudioPlayer.playSound(.Cancel)
        })
    }
    
    var body: some View {
        
        Game.MainButton(label: mode.name) {
            withAnimation{
                if viewModel.gkSelect {
                    if !GKLocalPlayer.local.isAuthenticated {
                        Game.errorHandler.showBanner(title: "Match Making Failed", message: "Login to Game Center to play online!")
                        
                    } else {
                        showMatchMakerModal.toggle()
                    }
                } else {
                    viewModel.startGame(mode: mode)
                }
            }
        }
        .contextMenu {
            Button(action: { deleteMode() })
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
                Game.errorHandler.showBanner(title: "Match Making Failed", message: error.localizedDescription)
            } started: { (match) in
                showMatchMakerModal = false
                viewModel.startGame(mode: mode)
                
            }
        }
    }
    
}

struct ModeSelectButton_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            ModeSelectButton(mode: .exampleNonDefault)

            ModeSelectButton(mode: .exampleDefault)
                
        }
        .environment(\.managedObjectContext, moc_preview)
        .environmentObject(WordBombGameViewModel.preview())
    }
}
