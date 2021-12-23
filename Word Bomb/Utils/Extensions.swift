//
//  Extensions.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Binary Search Extension for Array
extension Array where Element: Comparable {
    
    func search(element: Element) -> Int {
        
        var low = 0
        var high = count - 1
        var mid = Int(high / 2)
        
        while low <= high {
            
            let midElement = self[mid]
            
            if element == midElement {
                return mid
            }
            else if element < midElement {
                high = mid - 1
            }
            else {
                low = mid + 1
            }
            
            mid = (low + high) / 2
        }
        
        return -1
    }
    
}

extension Array where Element == (String, Int) {
    
    func bisect(at element: Int) -> Int {
        
        var low = 0
        var high = count - 1
        var mid = Int(high / 2)
        
        while low <= high {
            
            let midElement = self[mid].1
            
            if element == midElement {
                return mid
            }
            
            else if element < midElement {
                high = mid - 1
            }
            else {
                low = mid + 1
            }
            
            mid = (low + high) / 2
        }
        
        return mid
    }
}

extension Array {
    mutating func enqueue(_ element: Element) {
        self.append(element)
    }
    
    mutating func dequeue() -> Element? {
        self.count == 0 ? nil : self.removeFirst()
    }
}

extension Array where Element == Player {
    func find(_ player: Player) -> Int? {
        for i in self.indices {
            if self[i].id == player.id { return i }
        }
        return nil
    }
    
    func numPlaying() -> Int {
        var num = 0
        for player in self {
            if player.livesLeft > 0 { num += 1 }
        }
        
        return num
    }

    mutating func nextPlayer(_ currentPlayer: Player) -> Player {
        
        // if two players left do not rotate order for UI
        if self.count == 2  {
            
            if self.numPlaying() == 2 {
                print("2 player swap")
                if currentPlayer == self.first! { return self.last! }
                else { return self.first! }
            }
            // when one of the two loses, return the winning player as current player to show gameOver screen
            else if self.first!.livesLeft == 0 {
                return self.popLast()!
            }
            
            else if self.last!.livesLeft == 0 {
                return self.dequeue()!
            }
        }
        
        // cycle current player to back of queue if still playing
        if let currentPlayer = self.dequeue(), currentPlayer.livesLeft > 0 {
            print("\(currentPlayer.name) with \(currentPlayer.livesLeft) lives left going to back of queue")
            self.enqueue(currentPlayer)
        }
        return self.first! // there will always be at least 1 player in the array
    }

    mutating func reset() {
        for player in self {
            player.reset()
        }
    }
}

extension Collection where Index == Int {

    subscript(back i: Int) -> Iterator.Element {
        let backBy = i + 1
        return self[self.index(self.endIndex, offsetBy: -backBy)]
    }
}
