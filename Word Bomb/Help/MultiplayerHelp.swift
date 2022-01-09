//
//  MultiplayerHelp.swift
//  Word Bomb
//
//  Created by Brandon Thio on 8/1/22.
//

import Foundation
import SwiftUI

class MultiplayerHelpViewModel: ObservableObject, HelpViewModel {
    var correctCount = 15
    var timeLeft: Float = 10
    
    func isVisible(_ element: HelpElement) -> Bool {
        return (getHelpText(for: element) != nil)
    }
    
    var animateHelpTextPublished: Published<Bool> { _animateHelpText }
    
    var animateHelpTextPublisher: Published<Bool>.Publisher { $animateHelpText }
    
    @Published var focusedElement: HelpElement = .None
    
    var focusedElementPublished: Published<HelpElement> { _focusedElement }
    
    var focusedElementPublisher: Published<HelpElement>.Publisher { $focusedElement }
    
    @Published var animateHelpText = true
    
    func getHelpText(for element: HelpElement) -> String? {
        switch element {
        case .None:
            return "Welcome to the interactive tutorial for Multiplayer Games! \n\nTap on the various UI elements for more information"
        case .Timer:
            return "Shows the time remaining for the current turn. Players lose a life if they are unable to enter a correct answer before it runs out!"
        case .CorrectCount:
            return "Shows the number of words used. \n\nSince repeated words are not allowed, strategise your answers by tapping on this mid-game, which will show you which words have already been used."
        case .ChargeUp:
            return "Shows the extent of the current player's streak - that is, the amount of points accumulated since the player last ran out of time. \n\nFilling this bar up multiplies future points earned by up to x3!"
        case .Lives:
            return "Shows the number of lives remaining. In multiplayer games, the total number of lives is determined by the host player's setting. The game ends when every player runs out of lives."
        case .Avatar:
            return "It is this player's turn now!"
        case .Score:
            return "Shows the player's current score. Earn points by entering a valid English word that contains the given syllable. Longer words and harder syllables earn you more points!\n\nAt the end of the game, the player with the highest score wins! \n\nNote that if multiple players have the same score, then the game will enter a tiebreak. The tied players are given one life and continue competing until a single winner is found. "
        case .Query:
            return "In this example, 'in', 'dine' and 'international' are accepted answers. Notice that the answer does not have to start with 'in'. \n\nAlso, 'international' will earn the most points as it is a longer word. \n\nNote that repeat answers are not allowed."
        case .OtherPlayers:
            return "These are the other players in the match. \n\nThe left player's turn is coming next, while the right player's turn just ended."
        case .Rewards, .FreePass, .Pause, .Pass:
            return nil
        }
    }
    
    func getHelpTextOffset(for element: HelpElement) -> CGFloat? {
        switch element {
        case .None, .Timer, .CorrectCount, .Avatar, .OtherPlayers:
            return 0.45
        case .Lives:
            return 0.6
        case .Query:
            return 0.67
        case .Score:
            return 0.55
        case .ChargeUp:
            return 0.6
        case .Rewards, .FreePass, .Pause, .Pass:
            return nil
        }
    }
}

