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

}

extension GameMode : Identifiable {
    convenience init(context: NSManagedObjectContext,
                     gameType: GameType,
                     name: String,
                     instruction: String = "",
                     wordsDB: Database,
                     queriesDB: Database? = nil) {
        self.init(context: context)
        self.gameType = gameType
        self.name = name.trim().lowercased()
        self.instruction = instruction
        self.wordsDB = wordsDB
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
}
