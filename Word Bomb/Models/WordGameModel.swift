//
//  WordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation

protocol WordGameModel {
    var wordsDB: Database { get }
    var usedWords: Set<String> { get set }
    
    
    mutating func process(_ input: String, _ query: String?) -> (status: InputStatus, query: String?)
    mutating func updateUsedWords(input: Word)
    mutating func reset()
    mutating func getRandQuery(_ input: String?) -> String
}


