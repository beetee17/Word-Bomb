//
//  ArcadeHelp.swift
//  Word Bomb
//
//  Created by Brandon Thio on 7/1/22.
//

import SwiftUI

class ArcadeHelpViewModel: ObservableObject, HelpViewModel {
    var correctCount = 25
    var timeLeft: Float = 15
    
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
            return "Welcome to the interactive tutorial for Arcade Mode! \n\nTap on the various UI elements for more information"
        case .Pause:
            return "This is the pause button if you wish to quit or restart a game. Please note that to ensure fairness of leaderboard scores, this does not pause the game."
        case .Timer:
            return "Shows the time remaining for the round. Enter a correct answer before it runs out! You lose a life when the time reaches 0. \n\nIn Arcade Mode, you are given up to 15s for each round. As the game progresses, this limit gradually reduces to as low as 8s."
        case .CorrectCount:
            return "Shows the number of unique letters used as well as one of the letters that have not been used. \n\nIn this example, 'W' is the only letter left unused. You can also view all the unused letters by tapping on this mid-game. \n\nIn Arcade Mode, each time you use all 26 letters in the alphabet earns you a choice of two bonus rewards - an additional life or 5s more for future rounds!"
        case .Rewards:
            return "These are the bonus rewards that is shown after successfully using all 26 letters in the alphabet. \n\nIn Arcade Mode, selecting the heart earns you an additional life, while selecting the clock adds 5s to the time alloted for future rounds."
        case .ChargeUp:
            return "Shows the extent of the current streak - that is, the amount of points accumulated since you last ran out of time. \n\nFilling this bar up multiplies your future points earned by up to x3! It also gets you a free pass. Tap on the golden tickets for more information."
        case .FreePass:
            return "Redeeming the free pass allows you to skip the current syllable without penalty. \n\nSave them for situations where you are given a difficult syllable!"
        case .Lives:
            return "Shows the number of lives remaining. In Arcade Mode, you are given 3 lives, The game ends when you run out of lives. \n\nYou can get more by claiming the bonus reward for using all letters in the alphabet! Tap on the icon at the top right for more information."
        case .Avatar:
            return "This is your player avatar. Login to Game Center to see your profile picture here!"
        case .Score:
            return "Shows your current total score. Earn points by entering a valid English word that contains the given syllable. \n\nLonger words and harder syllables earn you more points!"
        case .Query:
            return "In this example, 'in', 'dine' and 'international' are accepted answers. Notice that the answer does not have to start with 'in'. \n\nAlso, 'international' will earn the most points as it is a longer word. \n\nNote that repeat answers are not allowed."
        case .OtherPlayers, .Pass:
            return nil
        }
    }
    
    func getHelpTextOffset(for element: HelpElement) -> CGFloat? {
        switch element {
        case .None, .Pause, .Timer, .CorrectCount, .Rewards, .ChargeUp, .FreePass, .Avatar, .Score:
            return 0.5
        case .Lives:
            return 0.6
        case .Query:
            return 0.67
        case .OtherPlayers, .Pass:
            return nil
        }
    }
}
