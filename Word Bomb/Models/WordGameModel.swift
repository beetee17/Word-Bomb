//
//  WordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation

/// Protocol for the structs that implement the game mechanism, mainly the processing of user input and generating random queries if necessary
protocol WordGameModel {
    
    /// Array that contains all the valid words for the given mode
    var words: [String] { get }
    /// Mapping from valid word to its variants (they are different accepted spellings of the same word)
    var variants: [String: [String]] { get }
    /// Set of words already used in the current game. Prevents players from giving the same answer more than once
    var usedWords: Set<String> { get set }
    
    var totalWords: Int { get set }
    
    /// Returns the outcome of the user input
    /// - Parameter input: The user input
    /// - Parameter query: The current query (if `.Classic` game type)
    /// - Returns: The `Response` object representing the outcome of the user input
    mutating func process(_ input: String, _ query: String?) -> Response
    
    /// Adds the given input to the set of used words. Should only be called when the input was correct
    mutating func updateUsedWords(for input: String)
    
    /// Resets the model, usually when restarting the game
    mutating func reset()
    
    /// Returns a random query from `queriesDB` based on the weighted distribution.
    /// Depends on the game mode and the outcome of the user input
    /// - Parameter input: Optional string corresponding to user input that is required in games of `.Reverse` type
    func getRandQuery(_ input: String?) -> String
    
    func getScore(for input: String, and query: String?) -> Int
}

struct Response: Codable {
    var status: InputStatus
    var score: Int
    var newQuery: String?
    
    init(status: InputStatus, score: Int = 0, newQuery: String? = nil) {
        self.status = status
        self.score = score
        self.newQuery = newQuery
    }
}


