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
    
    mutating func dequeue() -> Element? {
        self.count == 0 ? nil : self.removeFirst()
    }
}

extension Collection where Index == Int {

    subscript(back i: Int) -> Iterator.Element {
        let backBy = i + 1
        return self[self.index(self.endIndex, offsetBy: -backBy)]
    }
}
