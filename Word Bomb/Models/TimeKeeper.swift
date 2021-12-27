//
//  TimeKeeper.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import Foundation

struct TimeKeeper: Codable {
    
    /// The time allowed for each player, as per the host's settings. The limit may decrease with each turn depending on the other relevant settings
    var timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// The amount of time left for the current player.
    var timeLeft = UserDefaults.standard.float(forKey: "Time Limit")
    
    /// Updates the time limit based on the the `"Time Multiplier"` and `"Time Constraint"` settings
    mutating func updateTimeLimit() {
        // TODO: why do we need this conditional
//        if players.current == players.queue.first! {
            timeLimit = max(UserDefaults.standard.float(forKey:"Time Constraint"), timeLimit * UserDefaults.standard.float(forKey: "Time Multiplier"))
            print("time multiplied")
//        }
        timeLeft = timeLimit
    }
    mutating func reset() {
        timeLimit = UserDefaults.standard.float(forKey: "Time Limit")
        timeLeft = timeLimit
    }
}
