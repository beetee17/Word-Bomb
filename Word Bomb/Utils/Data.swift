//
//  Data.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/7/21.
//

import Foundation


// Loading of Data
func loadWords(_ filename: String) -> [[String]] {
    
    do {
        print("loading \(String(describing: filename))")
        guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
            print("no path found")
            return []
        }
        
        let rawData = try String(contentsOfFile: path, encoding: String.Encoding.utf8).components(separatedBy: "\n")
        let words =  rawData.map({ $0.components(separatedBy: ", ") })
        
        return words
        
    } catch {
        print(error.localizedDescription)
    }
    return []
}

func loadSyllables(_ filename: String) -> [(String, Int)] {
    var syllables = [(String, Int)]()
    
    
    do {
        print("loading syllables")
        guard let path = Bundle.main.path(forResource: filename, ofType: "txt") else {
            print("no path found")
            return []
        }
        
        let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        
        let items = string.components(separatedBy: "\n")
        
        for item in items {
            let components = item.components(separatedBy: " ")
            if components.count == 2 && components[0].trim().count != 0 {
                let syllable = components[0]
                
                guard let frequency = Int(components[1]) else {
                    print("Expected Number from \(components)")
                    continue
                    
                }
                syllables.append((syllable, frequency))
            }
            else {
                print("discarded syllable \(components)")
            }
        }
        
    }
    
    catch let error {
        Swift.print("Fatal Error: \(error.localizedDescription)")
    }
    
    
    return syllables
    
}

// for custom modes using core data
func encodeStrings(_ data: [String]) -> String {
    if let JSON = try? JSONEncoder().encode(data) {
        return String(data: JSON, encoding: .utf8)!
    } else { return "" }
}

func decodeJSONStringtoArray(_ json: String) -> [String] {
    if let data = try? JSONDecoder().decode([String].self, from: Data(json.utf8)) {
        return data.sorted()
    } else { return [] }
}

func encodeDict(_ dictionary: [String: String]) -> Data? {
    do {
        let data = try JSONEncoder().encode(dictionary)
        print("ENCODED JSON \(String(describing: String(data: data, encoding: .utf8)))")
        return data
        
    } catch {
        print("could not encode GK data")
        print(error.localizedDescription)
        return nil
    }
}


