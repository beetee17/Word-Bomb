//
//  WordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation

/// Protocol for the structs that implement the game mechanism, mainly the processing of user input and generating random queries if necessary
protocol WordGameModel {
    
    /// `Database` that contains all the valid words for the given mode
//    var wordsDB: Database { get }
    var words: [String] { get }
    var variants: [String: [String]] { get }
    /// Set of words already used in the current game. Prevents players from giving the same answer more than once
    var usedWords: Set<String> { get set }
    
    var totalWords: Int { get set }
    
    /// Returns the outcome of the user input
    /// - Parameter input: The user input
    /// - Parameter query: The current query (if `.Classic` game type)
    /// - Returns: The outcome of the user input
    mutating func process(_ input: String, _ query: String?) -> (status: InputStatus, query: String?)
    
    /// Adds the given input to the set of used words. Should only be called when the input was correct
//    mutating func updateUsedWords(input: Word)
    mutating func updateUsedWords(for input: String)
    
    /// Resets the model, usually when restarting the game
    mutating func reset()
    
    /// Returns a random query from `queriesDB` based on the weighted distribution.
    /// Depends on the game mode and the outcome of the user input
    /// - Parameter input: Optional string corresponding to user input that is required in games of `.Reverse` type
    func getRandQuery(_ input: String?) -> String
}


