//
//  FrenzyHelp.swift
//  Word Bomb
//
//  Created by Brandon Thio on 8/1/22.
//

import Foundation
import SwiftUI

class FrenzyHelpViewModel: ObservableObject, HelpViewModel {
    var correctCount = 25
    var timeLeft: Float = 90
    
    var animateHelpTextPublished: Published<Bool> { _animateHelpText }
    
    var animateHelpTextPublisher: Published<Bool>.Publisher { $animateHelpText }
    
    @Published var focusedElement: HelpElement = .None
    
    var focusedElementPublished: Published<HelpElement> { _focusedElement }
    
    var focusedElementPublisher: Published<HelpElement>.Publisher { $focusedElement }
    
    @Published var animateHelpText = true
    
    func isVisible(_ element: HelpElement) -> Bool {
        return (getHelpText(for: element) != nil)
    }
    func getHelpText(for element: HelpElement) -> String? {
        switch element {
        case .None:
            return "Welcome to the interactive tutorial for Frenzy Mode \n\nTap on the various UI elements for more information"
        case .Pause:
            return "This is the pause button if you wish to quit or restart a game."
        case .Timer:
            return "Shows the time remaining. In Frenzy Mode, the goal is to get as many points before it runs out! \n\nYou start with a total of 90s. Earn additional time by giving correct answers (1s), filling up the yellow bar (10s), or using all letters in the alphabet (25s)!"
        case .CorrectCount:
            return "Shows the number of unique letters used as well as one of the letters that have not been used. \n\nIn this example, 'W' is the only letter left unused. \n\nYou can also view all the unused letters by tapping on this mid-game. \n\nIn Frenzy Mode, each time you use all 26 letters in the alphabet earns you 25s of additional time!"
        case .Rewards:
            return "This is the bonus reward that becomes visible after successfully using all 26 letters in the alphabet. \n\nIn Frenzy Mode, claiming it gives you 25s of additional time."
        case .ChargeUp:
            return "Shows the extent of the current streak - that is, the amount of points accumulated since you last ran out of time. \n\nFilling this bar up multiplies your future points earned by up to x3! It also gets you a free pass. Tap on the golden tickets for more information. \n\nIn Frenzy Mode, it also earns you 10s of additional time."
        case .FreePass:
            return "Redeeming the free pass allows you to skip the current syllable without penalty. In Frenzy Mode, skipping the current syllable without a free pass (i.e. using the 'PASS' button) results in a -5s penalty. \n\nSave your free passes for situations where you are given a difficult syllable!"
        case .Avatar:
            return "This is your player avatar. Login to Game Center to see your profile picture here!"
        case .Score:
            return "Shows your current total score. Earn points by entering a valid English word that contains the given syllable. \n\nLonger words and harder syllables earn you more points!"
        case .Query:
            return "In this example, 'in', 'dine' and 'international' are accepted answers. Notice that the answer does not have to start with 'in'. \n\nAlso, 'international' will earn the most points as it is a longer word. \n\nNote that repeat answers are not allowed."
        case .Pass:
            return "In Frenzy Mode, tapping this button allows you to skip the current query. However, this will incur a -5s time penalty. \n\nTo skip without penalty, redeem a free pass instead! Tap on the golden ticket for more information."
        case .Lives:
            return nil
        case .OtherPlayers:
            return nil
        }
    }
    
    func getHelpTextOffset(for element: HelpElement) -> CGFloat? {
        switch element {
        case .None, .Pause, .Timer, .CorrectCount, .Rewards, .ChargeUp, .FreePass, .Avatar, .Score:
            return 0.5
        case .Pass:
            return 0.6
        case .Query:
            return 0.67
        case .Lives:
            return nil
        case .OtherPlayers:
            return nil
        }
    }
}
