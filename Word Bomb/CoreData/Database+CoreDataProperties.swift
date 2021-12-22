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
    
    var type: DBType {
        get {
            return DBType(rawValue: type_ ?? DBType.words.rawValue)!
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

    var words: [Word] {
        let set = words_ as? Set<Word> ?? []
        
        return set.sorted { $0.content < $1.content }
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
