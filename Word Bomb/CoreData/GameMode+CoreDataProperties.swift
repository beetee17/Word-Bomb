//
//  GameMode+CoreDataProperties.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/12/21.
//
//

import Foundation
import CoreData


extension GameMode {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GameMode> {
        return NSFetchRequest<GameMode>(entityName: "GameMode")
    }

    @NSManaged public var gameType_: String?
    @NSManaged public var instruction_: String?
    @NSManaged public var name_: String?
    @NSManaged public var wordsDB_: Database?
    @NSManaged public var queriesDB_: Database?
    @NSManaged public var isDefault_: Bool
    @NSManaged public var highScore_: Int32
    
}

extension GameMode : Identifiable {
    convenience init(context: NSManagedObjectContext,
                     gameType: GameType,
                     name: String,
                     instruction: String = "",
                     wordsDB: Database,
                     queriesDB: Database? = nil,
                     isDefault: Bool = false) {
        self.init(context: context)
        self.gameType = gameType
        self.isDefault_ = isDefault
        self.name = name.trim().lowercased()
        self.instruction = instruction
        self.wordsDB = wordsDB
        self.highScore = 0
        if let queries = queriesDB {
            self.queriesDB = queries
        }
    }
    
    var gameType: GameType {
        get {
            return GameType(rawValue: gameType_ ?? GameType.Classic.rawValue)!
        }
        set {
            gameType_ = newValue.rawValue
        }
    }
    var instruction: String {
        get {
            return instruction_ ?? "Unknown Instruction"
        }
        set {
            instruction_ = newValue
        }
    }
    var name: String {
        get {
            return name_ ?? "Unknown Name"
        }
        set {
            name_ = newValue
        }
    }
    var wordsDB: Database {
        get {
            return wordsDB_ ?? Database()
        }
        set {
            wordsDB_ = newValue
        }
    }
    var queriesDB: Database {
        get {
            return queriesDB_ ?? Database()
        }
        set {
            queriesDB_ = newValue
        }
    }
    
    var highScore: Int {
        get {
            return Int(highScore_)
        }
        set {
            highScore_ = Int32(newValue)
        }
    }
    func updateHighScore(with score: Int) {
        highScore = max(highScore, score)
        moc.saveObjects() 
    }
}

extension GameMode {
    static var exampleNonDefault: GameMode {
        GameMode(context: moc_preview, gameType: .Classic, name: "Deletable Mode", wordsDB: .exampleWords, queriesDB: .exampleSyllables)
    }
    static var exampleDefault: GameMode {
        GameMode(context: moc_preview, gameType: .Classic, name: "Not Deletable Mode", wordsDB: .exampleWords, queriesDB: .exampleSyllables, isDefault: true)
    }
}
