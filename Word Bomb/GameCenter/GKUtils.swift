//
//  Utils.swift
//  Word Bomb
//
//  Created by Brandon Thio on 23/7/21.
//

import Foundation
import GameKit
import GameKitUI

struct GameCenter {
    static var viewModel = GKMatchMakerAppModel()
    static var loginViewModel = AuthenticationViewModel()
    
    static var hostPlayerName: String? = nil
    
    static var isOnline: Bool { viewModel.showMatch }
    static var isHost: Bool { hostPlayerName == nil && isOnline }
    static var isNonHost: Bool { hostPlayerName != nil && isOnline  }
    
    static func getGKHostPlayer() -> [GKPlayer] {
        guard let gkMatch = viewModel.gkMatch else { return [] }
        for gkPlayer in gkMatch.players {
            if gkPlayer.displayName == GameCenter.hostPlayerName {
                return [gkPlayer]
            }
        }
        return []
    }
    
    static func send(_ data: GameData, toHost: Bool) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            
            switch toHost {
            case true:
                let hostPlayer = GameCenter.getGKHostPlayer()
                try viewModel.gkMatch?.send(data, to: hostPlayer, dataMode: .reliable)
            case false:
                try viewModel.gkMatch?.sendData(toAllPlayers: data, with: .reliable)
            }
//            print("SENT data \(data), to host: \(toHost)")
            print("SENT data, to host: \(toHost)")
        } catch {
            print("could not send GK data")
            print(error.localizedDescription)
        }
    }
    static func handleError(_ error: Error) -> (title: String, message: String) {
        if let error = error as? GKError {
            if error.code == GKError.notAuthenticated {
                return ("Authentication Failed", "Login to Game Center to play online!")
            }
            else if error.code == GKError.invalidCredentials {
                return ("Authentication Failed", "Invalid Login Credentials")
            }
        }
        return ("Authentication Failed", error.localizedDescription)
    }
    static func submitScore(of score: Int, to leaderboardID: LeaderBoardID) {
        if GKLocalPlayer.local.isAuthenticated {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID.rawValue]) { error in
                print("Score Upload to \(leaderboardID) with error: \(String(describing: error))")
                if error != nil  {
                    Game.errorHandler.showBanner(title: "Uploading Score to Game Center Failed", message: String(describing: error))
                }
            }
        } else {
            Game.errorHandler.showBanner(title: "Could Not Upload Score to Game Center", message: "Login to Game Center to compete with others!")
        }
    }
}

enum LeaderBoardID: String {
    case Frenzy = "Testing"
    case Arcade = "Arcade"
}
