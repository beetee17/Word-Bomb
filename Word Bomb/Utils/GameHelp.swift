//
//  GameHelp.swift
//  Word Bomb
//
//  Created by Brandon Thio on 28/7/21.
//

import SwiftUI

struct HelpMessage: Identifiable {
    var id = UUID()
    var content: String
    var subMessages: [HelpMessage]?
    
}

struct HelpButton: View {
    
    var action: () -> Void
    var border: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: action ) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                        .frame(width: 70, height: 100, alignment:.center) // tappable area
                        .background(border ? Color.white.opacity(0.2) : Color.clear)
                    
                }
                .clipShape(Circle().scale(0.8))
                .if(border) { $0.pulseEffect() }
            }
            Spacer()
        }
    }
}

struct HelpSheet: ViewModifier {
    
    @State private var showHelpSheet = false
    var action: () -> Void
    var messages = Game.helpMessages
    
    func body(content: Content) -> some View {
        ZStack {
            content
            HelpButton(action: {
                print("Show Help")
                action()
                showHelpSheet = true
            }, border: false)
            .sheet(isPresented: $showHelpSheet) {
                NavigationView {
                    List(messages, children: \.subMessages) {
                        item in
                        Text(item.content)
                            .font(item.subMessages == nil ? .system(.body, design: .rounded) : .system(.title3, design: .rounded).bold())
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle(Text("Help"))
                }
                
            }
            
        }
        .ignoresSafeArea(.all)
    }
}


extension Game {
    static let gameOverview = "Word Bomb is a multiplayer word game that allows you to test your quick-thinking and general knowledge of vocabulary or other custom categories such as countries.\n\nPlayers gain points by forming a word according to the game mode's instruction before their time runs out, which loses them a life. The game ends when all players run out of lives. The player with the most points is declared the winner of the game!"
    
    static let gameFAQ1 = "Q: What happens if multiple players end with the same points? \n\nA: The tied players are given 1 life each to compete until a single winner is found!\n"
    
    static let gameFAQ2 = "\nQ: What is that yellow progress bar for? \n\nA: The progress bar beside each player's avatar measures the number of points gained without since he/she last lost a life. Fill it up to multiply your score!\n"
    
    static let gameFAQ3 = "\nQ: How does the points system work? \n\nA: In the Classic Words game, the points awarded for a correct answer is in proportion to how uncommon the syllable given is in the English Dictionary. \n\nIn Exact game modes, a constant number of points is awarded for each correct answer"
    
    static let classicHelp = "In a Classic game, players are given a randomly generated syllable, and your task is to come up with a valid word that contains the syllable."
    static let exactHelp = "In an Exact game, you must come up with an answer that is found in the mode's database. For example, a database of countries would mean players are only allowed to name countries. You can create your own custom database to play with friends!"
    static let reverseHelp = "A Reverse game is similar to the Exact game, with the added constraint that the answer must start with the ending letter of the previous player's answer."
    
    static let singlePlayerHelp = "Play for a high score and compare them with your friends in the Single Player mode! Settings are fixed in single player games."
    static let singlePlayerFAQ = "Q: Are there any differences in Single Player games? \n\nA: Apart from the preset settings, players are given a bonus when they use all 26 letters of the alphabet. Tap the icon at the top right corner to see which letters are still required!"
    
    static let startGameHelp = "Press to start a game! Play solo, with Game Center friends, or even an offline, pass-and-play style game with a specified number of players and custom player names (this can be changed in the settings menu)."
    
    static let gameCenterHelp = "In order to play a game using Game Center, you need to be friends with the person who you are trying to play with. To do this, proceed to Settings App ⭢ Game Center ⭢ Add Friends.\n\nAfter you are friends with the people you want to play with, you can play with them by choosing this option!"
    
    static let createModeHelp = "The Create Mode button presents a sheet where you can create your own custom modes to play with friends."
    
    static let databaseHelp = "Here, you can search through the words used in the game to study and improve your future performances!\n\n You can also create your own database that can then be used in a custom mode to play with friends!"
    
    static let databaseHelpFAQ = "Q: Can I edit the inbuilt databases? \n\nA: It is not allowed to edit the default databases. However, if you would like to leverage them in your own database, simply make a copy of it and edit from there! \n\nYou may find this functionality in the 'Copy Existing' section in the 'Add Database' form or by force-pressing the name of the database you would like to duplicate."
    
    static let settingHelp = "Customise various settings of the game mechanics here. Relevant settings will also apply to online gameplay if you are the host!"
    
    static let helpMessages =
         [HelpMessage(content: "Game Objective",
                     subMessages: [
                        HelpMessage(content: gameOverview),
                        HelpMessage(content: "FAQ", subMessages: [HelpMessage(content: gameFAQ1 + gameFAQ2 + gameFAQ3)])
                    ]),
         
         HelpMessage(content: "Game Types",
                     subMessages: [
                        HelpMessage(content: "There are 3 game types currently available: Classic, Exact and Reverse."),
                        HelpMessage(content: "Classic", subMessages: [HelpMessage(content: classicHelp)]),
                        HelpMessage(content: "Exact", subMessages:[HelpMessage(content: exactHelp)]),
                        HelpMessage(content: "Reverse", subMessages: [HelpMessage(content: reverseHelp)])
                     ]),
         
         HelpMessage(content: "Single Player",
                     subMessages: [
                        HelpMessage(content: singlePlayerHelp),
                        HelpMessage(content: "FAQ", subMessages: [HelpMessage(content: singlePlayerFAQ)])
                    ]),
         
         HelpMessage(content: "Online Multiplayer",
                     subMessages: [HelpMessage(content: gameCenterHelp)]),
         
         HelpMessage(content: "Create Mode", subMessages: [HelpMessage(content: createModeHelp)]),
         
         HelpMessage(content: "Settings", subMessages: [HelpMessage(content: settingHelp)])
        ]
}
