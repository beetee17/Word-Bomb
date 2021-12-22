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

import os.log
import Combine
import Foundation
import GameKit
import GameKitUI

class GKMatchMakerAppModel: NSObject, ObservableObject {
    
    @Published public var showAlert = false
    @Published public var alertTitle: String = ""
    @Published public var alertMessage: String = ""
    
    @Published public var showAuthentication = false {
        didSet {
//            print("showAuthentication: local player is connected: \(GKLocalPlayer.local.isAuthenticated)")
            print("showAuthentication was set to \(showAuthentication)")
        }
    }
    @Published public var showInvite = false
    @Published public var showMatch = false
    
    
    @Published public var invite: Invite = Invite.zero {
        didSet {
            let sender = invite.gkInvite?.sender.displayName
            print("GK: Received Invite of \(invite) from \(sender) with Auth Status \(invite.needsToAuthenticate)")
            self.showInvite = invite.gkInvite != nil
            GameCenter.hostPlayerName = sender
            self.showAuthentication = invite.needsToAuthenticate ?? false
        }
    }
    @Published public var gkMatch: GKMatch?
    {
        didSet {
            if gkMatch != nil {
                self.showInvite = false
                self.showMatch = true
            }
        }
    }
    
    public var gkIsConnected: [GKPlayer : Bool] = [:]
    
    private var cancellableInvite: AnyCancellable?
    private var cancellableMatch: AnyCancellable?
    
    public override init() {
        super.init()
        self.subscribe()
    }
    
    deinit {
        self.unsubscribe()
    }
    
    func subscribe() {
        self.cancellableInvite = GKMatchManager
            .shared
            .invite
            .sink { (invite) in
                self.invite = invite
            }
        self.cancellableMatch = GKMatchManager
            .shared
            .match
            .sink { (match) in
                
                self.gkMatch = match.gkMatch
                self.gkMatch?.delegate = self
                if let gkMatch = match.gkMatch {
                    for player in gkMatch.players {
                        self.gkIsConnected[player] = true
                    }
                }
                else {
                    print("GKMatch was nil")
                    GameCenter.hostPlayerName = nil
                }
            }
    }
    
    func unsubscribe() {
        self.cancellableInvite?.cancel()
        self.cancellableMatch?.cancel()
    }
    
    public func showAlert(title: String, message: String) {
        self.showAlert = true
        self.alertTitle = title
        self.alertMessage = message
    }
    
    func cancel() {
        DispatchQueue.main.async {
            Game.viewModel.resetGameModel()
            GKMatchManager.shared.cancel()
            self.gkMatch = nil
            self.showMatch = false
            Game.viewModel.viewToShow = .main
        }
    }
}

extension GKMatchMakerAppModel: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let data = try JSONDecoder().decode(GameData.self, from: data)
            print("got data")
            data.process()
        }
        catch {
            print(String(describing: error))
        }
        
        do {
            print(String(data: data, encoding: .utf8) as Any)
            let data = try JSONDecoder().decode([String : String].self, from: data)
            if let hostPlayerName = data["Host Name"] {
                GameCenter.hostPlayerName = hostPlayerName
                print("Got host name \(hostPlayerName)")
            }
        }
        catch {
            print(String(describing: error))
        }
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
        DispatchQueue.main.async {
            self.gkIsConnected[player] = .disconnected == state ? false : true
            self.showAlert(title: "Connection Update", message: "\(player.displayName) has \(.disconnected == state ? "disconnected" : "connected")")
        }
        print("player \(player) connection status changed to \(state)")
        print("players left \(match.players)")
        print("$waiting to see if reconnection occurs... \(Date())")
        
        switch match.players.count > 0 {
        case true:
            // simply reset players without disconnected player
            DispatchQueue.main.async {
                Game.viewModel.handleDisconnected(from: player.displayName)
            }
            
        case false:
            //end the game as host if only one player (i.e the host) is left
            if GameCenter.isHost {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    
                    if !(self.gkIsConnected[player] ?? false) {
                        print(self.gkIsConnected)
                        print("$player still disconnected \(Date())")
                        match.disconnect()
                        match.delegate = nil
                        
                        self.cancel()
                        
                    }
                }
            }
        }
        
        if .disconnected == state && player.displayName == GameCenter.hostPlayerName {
            // exit the game if host disconnect
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                
                if !(self.gkIsConnected[player] ?? false) {
                    print(self.gkIsConnected)
                    print("$player still disconnected \(Date())")
                    GameCenter.hostPlayerName = nil
                    match.disconnect()
                    match.delegate = nil
                    self.cancel()
                }
            }
        }
    }
}



