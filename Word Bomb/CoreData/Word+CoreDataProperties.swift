//
//  Word+CoreDataProperties.swift
//  Word Bomb
//
//  Created by Brandon Thio on 3/8/21.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var content_: String?
    @NSManaged public var frequency_: Int32
    @NSManaged public var variant_: UUID?
    @NSManaged public var databases_: NSSet?
    
}

extension Word {
    convenience init(context: NSManagedObjectContext,
                     content: String,
                     frequency: Int = 1,
                     variant: UUID = UUID(),
                     db: Database? = nil) {
        self.init(context: context)
        self.content = content.trim().lowercased()
        self.frequency = frequency
        self.variant = variant
        if let db = db {
            self.addToDatabases_(db)
        }
    }
    
    var content: String {
        get {
            return content_ ?? "Unknown Content"
        }
        set {
            content_ = newValue
        }
    }
    
    var frequency: Int {
        get {
            return Int(frequency_)
        }
        set {
            frequency_ = Int32(newValue)
        }
    }
    
    var variant: UUID {
        get {
            return variant_ ?? UUID()
        }
        set {
            variant_ = newValue
        }
    }
    
    var databases: [Database] {
        let set = self.databases_ as? Set<Database> ?? []
        
        return set.sorted { $0.name < $1.name }
    }
    
}
// MARK: Generated accessors for databases
extension Word {

    @objc(addDatabases_Object:)
    @NSManaged public func addToDatabases_(_ value: Database)

    @objc(removeDatabases_Object:)
    @NSManaged public func removeFromDatabases_(_ value: Database)

    @objc(addDatabases_:)
    @NSManaged public func addToDatabases_(_ values: NSSet)

    @objc(removeDatabases_:)
    @NSManaged public func removeFromDatabases_(_ values: NSSet)

}
