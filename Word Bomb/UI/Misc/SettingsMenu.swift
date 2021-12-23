//
//  SettingsMenuView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 11/7/21.
//

import SwiftUI

struct SettingsMenu: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    @StateObject var settings = SettingsMenuVM()
    @Environment(\.presentationMode) var presentationMode
    
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
//                    Section(footer: Text("For debugging")) {
//                        Toggle("Debug", isOn:$gameVM.debugging)
//                    }
                    
                    Section(footer: Text("Buy me a drink!")) {
                        DonationButton(title: "Donate", productId: "onedollar")
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

struct DonationButton: View {
    @State var productPrice = ""
    var title: String
    var productId: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Button(productPrice) {
                PurchaseService.purchase(productId: "onedollar", successfulPurchase: { print( "Purchase Made")
                    
                })
            }
            .buttonStyle(DonateButtonStyle())
            .onAppear() { getProductPrice()}
        }
    }
    func getProductPrice() {
        PurchaseService.retrieve(productId) {  result in
            switch result {
            case .success(let product):
                productPrice = product.localizedPrice
            case .failure:
                productPrice = "$err"
            }
        }
    }
}

/// Source of truth for `SettingsMenu`. Handles the saving of game settings to `UserDefaults`
class SettingsMenuVM: ObservableObject {
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
}

struct SettingsMenuForm_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
