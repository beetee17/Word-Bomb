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


extension Game {
    static let gameOverview = "Word Bomb is a multiplayer word game that allows you to test your quick-thinking and vocabulary knowledge. \n\nPlayers gain points by forming a word according to the game mode's instruction before their time runs out, which loses them a life. \n\nThe game ends when all players run out of lives. The player with the most points is declared the winner of the game!"
    
    static let gameFAQ1 = "Q: What happens if multiple players end with the same points? \n\nA: The tied players are given 1 life each to compete until a single winner is found!\n"
    
    static let gameFAQ2 = "\nQ: What is that yellow progress bar for? \n\nA: The progress bar measures the number of points gained without since he/she last lost a life. Fill it up to multiply your score!\n"
    
    static let gameFAQ3 = "\nQ: How does the points system work? \n\nA: Points awarded for a correct answer is in proportion to how uncommon the syllable given is in the English Dictionary, as well as the length of the answer given."

    
    static let singlePlayerHelp = "Play for a high score and compare them with your friends in the Single Player mode! Settings are fixed in single player games."

    
    static let gameCenterHelp = "In order to play a game using Game Center, you need to be friends with the person who you are trying to play with. To do this, proceed to Settings App ⭢ Game Center ⭢ Add Friends.\n\nAfter you are friends with the people you want to play with, you can play with them by choosing this option!"
    
    static let databaseHelp = "Here, you can search through the words used in the game to study and improve your future performances!"
    
    
    static let settingHelp = "Customise various settings of the game mechanics here. Relevant settings will also apply to online gameplay if you are the host!"
    
    static let helpMessages =
         [HelpMessage(content: "Game Objective",
                     subMessages: [
                        HelpMessage(content: gameOverview),
                        HelpMessage(content: "FAQ", subMessages: [HelpMessage(content: gameFAQ1 + gameFAQ2 + gameFAQ3)])
                    ]),
         
         
         HelpMessage(content: "Single Player",
                     subMessages: [
                        HelpMessage(content: singlePlayerHelp)
                    ]),
         
         HelpMessage(content: "Online Multiplayer",
                     subMessages: [HelpMessage(content: gameCenterHelp)]),
         
         HelpMessage(content: "Settings", subMessages: [HelpMessage(content: settingHelp)])
        ]
}

struct HelpMessages: View {
    var body: some View {
        List(Game.helpMessages, children: \.subMessages) {
            item in
            Text(item.content)
                .font(item.subMessages == nil
                      ? .system(.body, design: .rounded)
                      : .system(.title3, design: .rounded).bold())
        }
    }
}
