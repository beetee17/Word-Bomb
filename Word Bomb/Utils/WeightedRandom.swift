//
//  WeightedRandom.swift
//  Word Bomb
//
// Created by Brandon Thio on 19/7/21.
// Credits https://codereview.stackexchange.com/questions/112605/weighted-probability-problem-in-swift

import Foundation

func weightedRandomElement<T>(items: [(T, Int)]) -> T {
    
    let total = items.map { $0.1 }.reduce(0, +)
    precondition(items.count > 0, "There must be at least 1 element")
    precondition(total > 0, "The sum of the weights must be positive")

    let rand = Int.random(in: 0 ..< total)

    var sum = 0
    
    for (element, weight) in items {
        sum += weight
        if rand < sum {
            return element
        }
    }

    fatalError("This should never be reached")
}

//is called like
//let colors : [(String, UInt)] = [("Red", 20), ("Blue", 50), ("Green", 70)]
//let color = weightedRandomElement(colors)
