//
//  ContainsWordGameModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation
import CoreData

/// Implements the mechanism for games of the `.Classic` type
struct ContainsWordGameModel: WordGameModel {
    var words: [String]
    var variants: [String : [String]] = [:]
    
    var queries: [(String, Int)] = []
    var queriesCopy: [(String, Int)] = []
    
    var usedWords = Set<String>()
    var totalWords: Int
    
    var pivot: Int
    var numTurns = 0
    var numTurnsBeforeDifficultyIncrease = 2
    
    init(variants: [String: [String]] = [:], queries: [(String, Int)], totalWords: Int) {
        self.words = variants.keys.sorted(by: {$0 < $1})
        self.variants = variants
        self.totalWords = totalWords
        
        self.queries = queries.sorted() { $0.1 < $1.1 }
        self.queriesCopy = self.queries

        self.pivot = 1000
    }
    
    mutating func process(_ input: String, _ query: String? = nil) -> Response {
        
        // pivot at some percentage of max element, defined by syllableDifficulty
        if numTurns % numTurnsBeforeDifficultyIncrease == 0 {
            updateSyllableWeights(pivot: pivot)
        }
        numTurns += 1
        
        let searchResult = words.search(element: input)
        if usedWords.contains(input) {
            print("\(input.uppercased()) ALREADY USED")
            return Response(status: .Used)
            
        }
        
        else if (searchResult != -1) && input.contains(query!) {
            print("\(input.uppercased()) IS CORRECT")
            return Response(status: .Correct, score: getScore(for: input, and: query), newQuery: getRandQuery(input))
        }
        
        else {
            print("\(input.uppercased()) IS WRONG")
            return Response(status: .Wrong)
            
        }
        
    }
    
    mutating func reset() {
        usedWords = Set<String>()
        queries = queriesCopy
        numTurns = 0
    }
    mutating func updateUsedWords(for input: String) {
        usedWords.insert(input)
        for variant in variants[input, default: []] {
            usedWords.insert(variant)
        }
    }
    
    func getRandQuery(_ input: String? = nil) -> String {
        
        var query = weightedRandomElement(items: queries).trim()
        
        while query.count == 0 && checkIfHasAtLeastOneUsableAnswer(query){
            // prevent blank query
            query = weightedRandomElement(items: queries).trim()
            print("getting random query \(query)")
        }
        print("GOT RANDOM QUERY \(query) with frequency \(String(describing: queries.first(where: { $0.0 == query })?.1))")
        
        return query
        
    }
    
    func getScore(for input: String, and query: String?) -> Int {
        if let frequency = queriesCopy.first(where: { $0.0 == query })?.1 {
            print("\(query) frequency \(frequency)")
            switch frequency {
            case 0...25:
                return 25
            case 26...100:
                return 15
            case 101...200:
                return 10
            case 201...500:
                return 5
            case 501...1000:
                return 3
            default:
                return 1
            }
        }
        print("Query \(query) not found?")
        return 1
    }
    
    func checkIfHasAtLeastOneUsableAnswer(_ query: String) -> Bool {
        // first check in used words -> iff there has been no answers used then there must be at least one usable answer
        var atLeastOneUsableAnswer = true
        for word in usedWords {
            if word.contains(query) { atLeastOneUsableAnswer = false}
        }

        if atLeastOneUsableAnswer { return true }
        
        // need to check database for one usable answer
        for word in words {
            if word.contains(query) && !usedWords.contains(word) { return true }
        }
        
        return false
        
    }
    
    mutating func updateSyllableWeights(pivot: Int) {
        // TODO: Make difficulty smoother and customisable if possible
        // Need to graph this distribution over time to visualise what's happening
        for i in queries.indices {
            let weight = queries[i].1
            let currentOffset = Int(Double(abs(queries[i].1 - queries[pivot].1)) * 0.05)
            
            if i < pivot {
                queries[i] = (queries[i].0, weight + currentOffset)
            } else {
                queries[i] = (queries[i].0, weight - currentOffset)
            }

            
            
            //            if i < 600 && i > 590{
            //                print(queries[i])
            //
            //            }
            
        }
        //        print("pivot \(queries[pivot])")
        
    }
    
}

