//
//  CustomMergePolicy.swift
//  Word Bomb
//
//  Created by Brandon Thio on 18/12/21.
//

import Foundation
import CoreData

/// Custom `NSMergePolicy` that extends `.overwrite` to ensure uniqueness of `Word.content` on a per `Database` basis (i.e. any `Database` cannot have duplicates of the same word)
class CustomMergePolicy: NSMergePolicy {
    
    init() {
        super.init(merge: .overwriteMergePolicyType)
    }

    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {

        for conflict in list {
            guard let object = conflict.databaseObject else {
                try super.resolve(constraintConflicts: list)
                return
            }
            let allKeys = object.entity.attributesByName.keys
            
            for conflictingObject in conflict.conflictingObjects {
                print("CONFLICT: \(conflictingObject)")
                let changedKeys = conflictingObject.changedValues().keys
                let keys = allKeys.filter { !changedKeys.contains($0) }
                
                for key in keys {
                    let value = object.value(forKey: key)
                    conflictingObject.setValue(value, forKey: key)
                }
                if let newDB = conflictingObject as? Database {
                    let existingDB = object as! Database
                    print("DB CONFLICT \(newDB.name) \nexisting: \(existingDB.words.map({ $0.content })) \nnew:\(newDB.words.map({ $0.content }))")
                    newDB.addToWords_(existingDB.words_ ?? NSSet())
                }
                
                else if let newWord = conflictingObject as? Word {
                    let existingWord = object as! Word
                    print("WORD CONFLICT: \(newWord.content) \nexisting: \(existingWord.databases.map({ $0.name })) \nnew: \(newWord.databases.map({ $0.name }))")
                    newWord.addToDatabases_(existingWord.databases_ ?? NSSet())
                }
            }
        }
        // overwrites existing objects with new objects
        try super.resolve(constraintConflicts: list)
    }
}
