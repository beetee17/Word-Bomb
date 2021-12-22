//
//  GKHostText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 26/7/21.
//

import SwiftUI
import GameKit

struct GKHostText: View {
    let hostText = "\(GameCenter.isHost ? GKLocalPlayer.local.displayName : GameCenter.hostPlayerName ?? "NIL") IS HOSTING"
    var body: some View {
        VStack() {
            Spacer()
            HStack {
                Spacer()
                Text(hostText)
                    .font(.caption)
                    .foregroundColor(.green)
                    .ignoresSafeArea(.all)
            }
        }
    }
}

struct GKHostText_Previews: PreviewProvider {
    static var previews: some View {
        GKHostText()
    }
}
