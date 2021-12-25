//
//  PlayerEditorView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 11/7/21.
//

import SwiftUI

struct PlayerEditorView: View {
    @Binding var playerNames: [String]
    var numPlayers: Int
    var body: some View {
        
        Form {
            ForEach(1...numPlayers, id:\.self ) { index in
                
                Section(header: Text("Player \(index)")) {
                    TextField("Player \(index)", text: Binding(
                        get: {
                        if index-1 >= playerNames.count { return "Player" }
                        else { return playerNames[index-1] }
                    },
                        
                        set: { (newValue) in
                        if newValue.trim() != "" {
                            self.playerNames[index-1] = newValue
                            
                        }
                    }))
                    
                        .autocapitalization(.words)
                    
                }
            }
        }
        .navigationTitle(Text("Edit Player Names"))
        .onAppear() {
            for index in 1...numPlayers {
                if index-1 >= playerNames.count {
                    playerNames.append("Player \(index)")
                }
            }
        }
    }
}

struct PlayerEditorView_Previews: PreviewProvider {
    
    struct PlayerEditorView_Harness: View {
        
        @State private var playerNames: [String] = ["Test Player 1"]
        private var numPlayers = 3
        
        var body: some View {
            PlayerEditorView(playerNames: $playerNames, numPlayers: numPlayers)
        }
    }
    
    static var previews: some View {
        PlayerEditorView_Harness()
    }
}
