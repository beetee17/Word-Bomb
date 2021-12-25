//
//  ExactWordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation
import CoreData

/// Implements the mechanism for games of the `.Exact` type
struct ExactWordGameModel: WordGameModel {
    var wordsDB: Database
    var usedWords = Set<String>()
    var totalWords: Int
    
    init(wordsDB: Database) {
        self.wordsDB = wordsDB
        totalWords = moc.getUniqueWords(db: wordsDB)
    }
    
    mutating func updateUsedWords(input: Word) {
        let request = Word.fetchRequest()
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@ AND variant_ = %@", wordsDB, "\(input.variant)")
        
        let variants = moc.safeFetch(request).map({ $0.content })
        
        print("variants of \(input.content): \(variants)")
        
        for variant in variants {
            usedWords.insert(variant)
        }
    }
    
    mutating func process(_ input: String, _ query: String? = nil) -> (status: InputStatus, query: String?) {
        
        if usedWords.contains(input) {
            print("\(input.uppercased()) ALREADY USED")
            return (.Used, nil)
        }
        
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@ AND content_ == %@", wordsDB, input)
        let searchResult = moc.safeFetch(request)
        
        if searchResult.count != 0 {
            print("\(input.uppercased()) IS CORRECT")
            
            updateUsedWords(input: searchResult.first!)
            
            return (.Correct, nil)
            
        }
                
        else {
            print("\(input.uppercased()) IS WRONG")
            return (.Wrong, nil)
        }
    }
    
    mutating func reset() {
        usedWords = Set<String>()
    }
    mutating func getRandQuery(_ input: String? = nil) -> String { return "" }

}
