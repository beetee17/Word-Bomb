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

/**
 View model that handles most of the Game Center aspects
 
 Including but not limited to:
 - Sending/receiving of game data as host or non-host
 - Handling the receipt of match invitations
 - Detecting player disconnections
 */
class GKMatchMakerAppModel: NSObject, ObservableObject {
    
    /// Determines if `GKInvitationView` should be displayed. Should be true when a non-nil `GKInvite` is received.
    @Published public var showInvite = false
    
    /// Determines if `GamePlayView(gkMatch: gkMatch)` should be displayed. Should be true when `gkMatch` is non-nil
    @Published public var showMatch = false
    
    /// The current invitation to be handled.
    @Published public var invite: Invite = Invite.zero {
        didSet {
            let sender = invite.gkInvite?.sender.displayName
            print("GK: Received Invite of \(invite) from \(sender ?? "Unknown Sender") with Authentication Status \(String(describing: invite.needsToAuthenticate))")
            self.showInvite = invite.gkInvite != nil
            GameCenter.hostPlayerName = sender
        }
    }
    
    /// The current `GKMatch` to play, if any
    @Published public var gkMatch: GKMatch?
    {
        didSet {
            // Transition to the GamePlayView if not nil
            if gkMatch != nil {
                self.showInvite = false
                self.showMatch = true
            }
        }
    }
    
    /// Mapping from each participating `GKPlayer` to a boolean that is `true` if the `GKPlayer` is connected to `gkMatch`
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
    
    /**
     Cancels the current `GKMatch`.
     Should be called when:
     - The user taps on the Quit Button
     - As a non-host player, if the host player disconnects
     - As the host player, if there are no non-host players in the match
     */
    func cancel() {
        DispatchQueue.main.async {
            Game.viewModel.resetGameModel()
            GKMatchManager.shared.cancel()
            self.gkMatch = nil
            self.showMatch = false
            Game.viewModel.viewToShow = .Main
        }
    }
}

extension GKMatchMakerAppModel: GKMatchDelegate {
    
    /// Inherited from GKMatchDelegate.match(_:didReceive:fromRemotePlayer:). Handles the receipt of data depending on whether user if host or non-host.
    /// The host mainly receives user input to be processed from non-host players
    /// Non-host players mainly receive data to sync game state with the host
    /// - Parameters:
    ///   - match: The current `GKMatch`
    ///   - data: The data received by the user
    ///   - player: The sender of the data
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        do {
            let data = try JSONDecoder().decode(GameData.self, from: data)
            print("got GameData")
            data.process()
        }
        catch {
            print(String(describing: error))
            print("error trying to decode data, maybe this was not GameData")
        }
    }
    
    /*
     Inherited from GKMatchDelegate.match(_:player:didChange:). Handles change in connection state of the participating players.
     
     Cancel the `GKMatch` if too many non-hosts have disconnected, or if the host player has disconnected
     When a non-host player disconnects, remove the player from the match
     - Parameters:
     - match: The current `GKMatch`
     - player: The `GKPlayer` whose connection status has changed
     - state: The current connection state of `player`
     */
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        
        DispatchQueue.main.async {
            self.gkIsConnected[player] = .disconnected == state ? false : true
            Game.errorHandler.showBanner(title: "Connection Update", message: "\(player.displayName) has \(.disconnected == state ? "disconnected" : "connected")")
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



