//
//  ReverseWordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 9/7/21.
//

import Foundation
import CoreData

/// Implements the mechanism for games of the `.Reverse` type
struct ReverseWordGameModel: WordGameModel {
    var words: [String]
    var usedWords = Set<String>()
    var totalWords: Int
    var variants: [String: [String]]
    
    init(variants: [String: [String]] = [:], totalWords: Int) {
        self.words = variants.keys.sorted(by: {$0 < $1})
        self.variants = variants
        self.totalWords = totalWords
    }
    
    mutating func process(_ input: String, _ query: String? = nil) -> (status: InputStatus, query: String?) {
        
        if usedWords.contains(input) {
            print("\(input.uppercased()) ALREADY USED")
            return (.Used, nil)
            
        }
        let searchResult = words.search(element: input)
        if searchResult != -1 && input.first == query!.last {
            print("\(input.uppercased()) IS CORRECT")
            
            updateUsedWords(for: input)
            
            return (.Correct, getRandQuery(input))
            
        }
        
        else {
            print("\(input.uppercased()) IS WRONG")
            return (.Wrong, nil)
            
        }
    }
    
    mutating func updateUsedWords(for input: String) {
        usedWords.insert(input)
        for variant in variants[input, default: []] {
            usedWords.insert(variant)
        }
    }
    
    mutating func reset() {
        usedWords = Set<String>()
    }
    func getRandQuery(_ input: String? = nil) -> String {
        if let input = input {
            return String(input.last!)
            
        }
        else {
            return String(words.randomElement()!.trim().last!)
        }
    }
}

