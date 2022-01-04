//
//  Database+CoreDataProperties.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/12/21.
//
//

import Foundation
import CoreData


extension Database {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Database> {
        return NSFetchRequest<Database>(entityName: "Database")
    }

    @NSManaged public var name_: String?
    @NSManaged public var type_: String?
    @NSManaged public var isDefault_: Bool
    @NSManaged public var words_: NSSet?

}

extension Database {
    convenience init(context: NSManagedObjectContext,
                     name: String, type: DBType, items: [Any]? = nil, isDefault: Bool = false) {
        self.init(context: context)
        self.name = name.trim().lowercased()
        self.type = type
        self.isDefault_ = isDefault
        if let items = items as? [String] {
            for item in items {
                self.addToWords_(Word(context: context, content: item))
            }
        }
        else if let items = items as? [Word] {
            for item in items {
                self.addToWords_(item)
            }
        }
    }
    
    convenience init(context: NSManagedObjectContext,
                     name: String, db: Database) {
        // for duplicating a database
        self.init(context: context)
        self.name = name.trim().lowercased()
        self.type = db.type
        self.isDefault_ =  false
        self.addToWords_(db.words_ ?? NSSet())
    }
    
    var type: DBType {
        get {
            return DBType(rawValue: type_ ?? DBType.Words.rawValue)!
        }
        set {
            type_ = newValue.rawValue
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

    var words: [String] {
        let array = words_ as? Set<Word> ?? []
        
        return array.map({ $0.content }).sorted()
    }
    
    var wordArray: [Word] {
        let array = words_ as? Set<Word> ?? []
        
        return array.sorted() { $0.content < $1.content }
    }
    
    func remove(_ words: Set<Word>) {
        for word in words {
            self.removeFromWords_(word)
        }
    }
    func empty() {
        guard let words = self.words_ else { return }
        self.removeFromWords_(words)
    }
}

// MARK: Generated accessors for words_
extension Database {

    @objc(addWords_Object:)
    @NSManaged public func addToWords_(_ value: Word)

    @objc(removeWords_Object:)
    @NSManaged public func removeFromWords_(_ value: Word)

    @objc(addWords_:)
    @NSManaged public func addToWords_(_ values: NSSet)

    @objc(removeWords_:)
    @NSManaged public func removeFromWords_(_ values: NSSet)

}

extension Database : Identifiable {

}

extension Database {
    static var exampleWords: Database {
        Database(context: moc_preview, name: "Example Words", type: .Words, items: ["word1", "word2", "word3"], isDefault: true)
    }
    static var exampleSyllables: Database {
        Database(context: moc_preview, name: "Example syllables", type: .Queries, items: ["syllable1", "syllable2", "syllable3"])
    }
}
