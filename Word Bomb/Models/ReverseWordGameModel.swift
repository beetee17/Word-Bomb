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
    
    var wordsDB: Database
    var usedWords = Set<String>()
    
    mutating func process(_ input: String, _ query: String? = nil) -> (status: InputStatus, query: String?) {
  
        if usedWords.contains(input) {
            print("\(input.uppercased()) ALREADY USED")
            return (.Used, nil)
           
        }
        if input.first != query?.last {
            print("\(input.uppercased()) IS WRONG")
            return (.Wrong, nil)
        }
        
        let request = Word.fetchRequest()
        
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@ AND content_ == %@", wordsDB, input)
        request.fetchLimit = 1
        let searchResult = moc.safeFetch(request)
        print(searchResult)
        
        if searchResult.count != 0 {
            print("\(input.uppercased()) IS CORRECT")
            updateUsedWords(input: searchResult.first!)
            
            return (.Correct, getRandQuery(input))
 
        }
                
        else {
            print("\(input.uppercased()) IS WRONG")
            return (.Wrong, nil)
          
        }
    }
    
    mutating func updateUsedWords(input: Word) {
        let request = Word.fetchRequest()
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@ AND variant_ = %@", wordsDB, "\(input.variant)")
        
        let variants = try! moc.fetch(request).map({ $0.content })
        
        print("variants of \(input.content): \(variants)")
        
        for variant in variants {
            usedWords.insert(variant)
        }
    }
    
    mutating func reset() {
        usedWords = Set<String>()
    }
    
    mutating func getRandQuery(_ input: String? = nil) -> String {
        if let input = input {
            return String(input.last!)
            
        }
        else {
            
            let request: NSFetchRequest<Word> = Word.fetchRequest()
            request.predicate = NSPredicate(format: "databases_ CONTAINS %@ AND TRUEPREDICATE", wordsDB)
            
            let count = try! moc.count(for: request)
            precondition(count > 0)
            
            request.fetchOffset = Int.random(in: 0..<count)
            request.fetchLimit = 1

            let res = try! moc.fetch(request)
            return String(res.first!.content.first!)
        }
    }

}

