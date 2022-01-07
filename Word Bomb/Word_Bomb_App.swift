//
//  Word_Bomb_App.swift
//  Word Bomb
//
//  Created by Brandon Thio on 1/7/21.
//

import SwiftUI
import GameKit
import GameKitUI
import CoreData
import Purchases

let moc = PersistenceController.shared.container.viewContext
let moc_preview = PersistenceController.preview.container.viewContext

@main
struct Word_BombApp: App {
    
    @ObservedObject var errorHandler = Game.errorHandler
    @ObservedObject var gkViewModel = GameCenter.viewModel
    @ObservedObject var cdViewModel = CoreDataViewModel()
    @ObservedObject var gameViewModel = Game.viewModel
    
    init() {
        // register "default defaults"
        UserDefaults.standard.register(defaults: [
            "First Launch" : true,
            "Set Up Completed" : false,
            "Time Limit" : 10.0,
            "Time Multiplier" : 0.95,
            "Time Constraint" : 5.0,
            "Player Names" : ["A", "B", "C"],
            "Num Players" : 2,
            "Player Lives" : 3
            
            // ... other settings
        ])
        
        moc.automaticallyMergesChangesFromParent = true
        
        // Initialise Revenue Cat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_PbFyqlyrPaJzyFUtKnwBuUxLvNN")
    }
    @State private var authRequired = true
    @State private var authenticated = GKLocalPlayer.local.isAuthenticated
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !authenticated {
                    // Hacky workaround to fix game center invite crashes
                    GKAuthenticationView { (error) in
                        let errorDisplay = GameCenter.handleError(error)
                        errorHandler.showBanner(title: errorDisplay.title, message: errorDisplay.message) // change to something more user friendly on release?
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            authenticated = true
                        }
                    } authenticated: { (player) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            authenticated = true
                        }
                    }
                } else if gkViewModel.showInvite {
                    if authRequired {
                        GKAuthenticationView { (error) in
                            let errorDisplay = GameCenter.handleError(error)
                            errorHandler.showBanner(title: errorDisplay.title, message: errorDisplay.message) // change to something more user friendly on release?
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                authRequired.toggle()
                            }
                        } authenticated: { (player) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                authRequired.toggle()
                            }
                        }
                    } else {
                        GKInviteView(
                            invite: gkViewModel.invite.gkInvite!
                        ) {
                        } failed: { (error) in
                            gkViewModel.showInvite = false
                            errorHandler.showBanner(title: "Invitation Failed", message: "Sorry, please try again!") // change to something more user friendly on release?
                            
                        } started: { (gkMatch) in
                            Game.viewModel.viewToShow = .Waiting
                            gkViewModel.gkMatch = gkMatch
                            
                        }
                    }
                    
                } else {
                    ContentView()
                }
                
            }
            .banner(isPresented: $errorHandler.bannerIsShown, title: errorHandler.bannerTitle, message: errorHandler.bannerMessage)
            .environmentObject(gameViewModel)
            .environmentObject(GameCenter.viewModel)
            .environmentObject(GameCenter.loginViewModel)
            .environmentObject(cdViewModel)
            .environmentObject(Game.errorHandler)
            .environment(\.managedObjectContext, moc)
            .onAppear() {
                AudioPlayer.playSoundTrack(.BGMusic)
            }
        }
    }
}

