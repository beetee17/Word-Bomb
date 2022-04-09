//
//  SettingsMenuView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 11/7/21.
//

import SwiftUI
import RevenueCat

struct SettingsMenu: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @ObservedObject var settings = SettingsMenuVM.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var IAPHandler = UserViewModel.shared
    /// - The current offering saved from PurchasesDelegateHandler
    private(set) var offering: Offering? = UserViewModel.shared.offerings?.current
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    
                    Section(footer: Text("Number of players in offline gameplay.")) {
                        Stepper("Number of Players: \(settings.numPlayers)", value: $settings.numPlayers, in: 2...10)
                        NavigationLink("Edit Player Names", destination: PlayerEditorView(playerNames: $settings.playerNames, numPlayers: settings.numPlayers))
                    }
                    
                    Section(footer: Text("Number of lives each player starts with.")) {
                        
                        Stepper("Player Lives: \(settings.playerLives)", value: $settings.playerLives, in: 1...10)
                        
                        HStack {
                            
                            ForEach(0..<settings.playerLives, id: \.self) { i in
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                            
                        }
                    }
                    
                    Section(footer: Text("Initial time given to each player.")) {
                        Stepper("Time Limit: \(settings.timeLimit, specifier: "%.1f") s", value: $settings.timeLimit, in: 1...50, step: 0.5)
                    }
                    
                    Section(footer: Text("Factor applied to the time limit after each round.")) {
                        Stepper("Time Multiplier: \(settings.timeMultipier, specifier: "%.2f")", value: $settings.timeMultipier, in: 0.7...1, step: 0.01)
                    }
                    
                    Section(footer: Text("Minimum amount of time allowed for each turn.")) {
                        Stepper("Time Constraint: \(settings.timeConstraint, specifier: "%.1f") s", value: $settings.timeConstraint, in: 1...settings.timeLimit, step: 0.5)
                        
                    }
                    
                    Section {
                        Toggle("Sound FXs", isOn: $settings.soundFXs)
                        Slider(value: $settings.soundFXVolume, in: 0...2)
                    }
                    
                    Section {
                        Toggle("Soundtrack", isOn: $settings.soundTrack)
                        Slider(value: $settings.soundTrackVolume, in: 0...2)
                    }
                    
                    //                    Section(footer: Text("For debugging")) {
                    //                        Toggle("Debug", isOn: $viewModel.debugging)
                    //                    }
                    
                    Section(footer: Text("Remove all ads from the game (buys me a drink too!)")) {
                        List {
                            ForEach(offering?.availablePackages ?? []) { package in
                                PackageCellView(package: package) { (package) in
                                    
                                    /// - Purchase a package
                                    Purchases.shared.purchase(package: package) { (transaction, info, error, userCancelled) in
                                        IAPHandler.customerInfo = info
                                    }
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button(action: { Purchases.shared.restorePurchases(completion: nil) }) {
                            Text("Restore Purchases")
                                .font(.title3)
                        }
                    }
                    
                }
                .navigationBarTitle(Text("Settings"))
            }
            .onDisappear() {
                viewModel.updateGameSettings()
            }
        }
    }
    
}
/* The cell view for each package */
struct PackageCellView: View {
    let package: Package
    let onSelection: (Package) -> Void
    
    var body: some View {
        Button(action: { onSelection(package) }) {
            HStack {
                VStack {
                    HStack {
                        Text(package.storeProduct.localizedTitle)
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                        
                        Spacer()
                    }
                }
                .padding([.top, .bottom], 8.0)
                
                Spacer()
                
                
                Text(UserViewModel.shared.subscriptionActive ? "Purchased" : package.localizedPriceString)
                    .font(.title3)
                    .bold()
                
            }
            .contentShape(Rectangle()) // Make the whole cell tappable
        }
    }
}


/// Source of truth for `SettingsMenu`. Handles the saving of game settings to `UserDefaults`
class SettingsMenuVM: ObservableObject {
    static let shared = SettingsMenuVM()
    
    @Published var numPlayers = UserDefaults.standard.integer(forKey: "Num Players") {
        didSet {
            UserDefaults.standard.set(numPlayers, forKey: "Num Players")
        }
    }
    
    @Published var playerNames = UserDefaults.standard.stringArray(forKey: "Player Names")! {
        didSet {
            UserDefaults.standard.set(playerNames, forKey: "Player Names")
        }
    }
    @Published var playerLives = UserDefaults.standard.integer(forKey: "Player Lives") {
        didSet {
            UserDefaults.standard.set(playerLives, forKey: "Player Lives")
        }
    }
    @Published var timeLimit = UserDefaults.standard.float(forKey: "Time Limit") {
        didSet {
            UserDefaults.standard.set(timeLimit, forKey: "Time Limit")
            timeConstraint = min(timeLimit, timeConstraint)
        }
    }
    @Published var timeMultipier = UserDefaults.standard.float(forKey: "Time Multiplier") {
        didSet {
            UserDefaults.standard.set(timeMultipier, forKey: "Time Multiplier")
        }
    }
    @Published var timeConstraint = UserDefaults.standard.float(forKey: "Time Constraint") {
        didSet {
            UserDefaults.standard.set(timeConstraint, forKey: "Time Constraint")
        }
    }
    @Published var soundFXs = UserDefaults.standard.bool(forKey: "Sound FXs") {
        didSet {
            UserDefaults.standard.set(soundFXs, forKey: "Sound FXs")
        }
    }
    
    @Published var soundFXVolume = UserDefaults.standard.float(forKey: "SoundFX Volume") {
        didSet {
            UserDefaults.standard.set(soundFXVolume, forKey: "SoundFX Volume")
        }
    }
    
    @Published var soundTrack = UserDefaults.standard.bool(forKey: "Soundtrack") {
        didSet {
            UserDefaults.standard.set(soundTrack, forKey: "Soundtrack")
            if soundTrack {
                AudioPlayer.playSoundTrack(.BGMusic)
            } else {
                AudioPlayer.soundTrack?.pause()
            }
        }
    }
    
    @Published var soundTrackVolume = UserDefaults.standard.float(forKey: "Soundtrack Volume") {
        didSet {
            UserDefaults.standard.set(soundTrackVolume, forKey: "Soundtrack Volume")
            AudioPlayer.soundTrack?.scaleVolume(by: soundTrackVolume)
        }
    }
}

struct SettingsMenuForm_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
            .environmentObject(WordBombGameViewModel())
    }
}
