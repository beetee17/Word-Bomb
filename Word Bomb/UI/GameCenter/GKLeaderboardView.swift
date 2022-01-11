//
//  GKLeaderboardView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 9/1/22.
//

import SwiftUI
import GameKit

struct GKLeaderboardView: UIViewControllerRepresentable {
    
    var leaderboardID: LeaderBoardID = .Arcade
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.parent?.dismiss(animated: true)
        }
        
        var parent: GKLeaderboardView
        
        init(_ parent: GKLeaderboardView) {
            self.parent = parent
        }
        
    }
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let leaderboard = GKGameCenterViewController(leaderboardID: leaderboardID.rawValue, playerScope: .global, timeScope: .allTime)
        leaderboard.gameCenterDelegate = context.coordinator
        return leaderboard
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
}

struct GKLeaderboardUI: View {
    @State private var isShowing = false
    var body: some View {
        VStack {
            Game.MainButton(label: "Show leaderboard") {
                isShowing.toggle()
            }
            Game.MainButton(label: "Submit Score of 10") {
                GameCenter.submitScore(of: 10, to: .Frenzy)
            }
            
        }
        .sheet(isPresented: $isShowing) {
            GKLeaderboardView(leaderboardID: .Frenzy)
        }
    }
}


struct GKLeaderboardUI_Previews: PreviewProvider {
    static var previews: some View {
        GKLeaderboardUI()
    }
}
