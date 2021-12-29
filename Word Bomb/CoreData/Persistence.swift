//
//  Persistence.swift
//  wordbomb
//
//  Created by Brandon Thio on 7/7/21.
//

import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let defaultDB = Database(context: viewContext, name: "default database", type: .words, items: ["word1", "word2", "word3"], isDefault: true)
        
        let wordsPreview1 = Database(context: viewContext, name: "non-empty words", type: .words, items: ["word1", "word2", "word3"])
        
        let wordsPreview2 = Database(context: viewContext, name: "empty words", type: .words)
        
        let syllablesPreview1 = Database(context: viewContext, name: "non-empty syllables", type: .queries, items: ["syllable1", "syllable2", "syllable3"])
        
        let syllablesPreview2 = Database(context: viewContext, name: "empty syllables", type: .queries)
        
        for type in GameType.allCases {
            
            let defaultMode = GameMode(context: viewContext, gameType: type, name: "(Default) Test Mode 1", instruction: "Test Instruction", wordsDB: wordsPreview1, queriesDB: syllablesPreview1, isDefault: true)
            
            for i in 2...4 {
                let newMode = GameMode(context: viewContext, gameType: type, name: "Test Mode \(i)", instruction: "Test Instruction", wordsDB: wordsPreview1, queriesDB: syllablesPreview1)
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "wordbomb")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [self] description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                return
            }

            container.viewContext.mergePolicy = CustomMergePolicy()
            
            // support for lightweight migrations
            let description = NSPersistentStoreDescription()
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions.append(description)
        }
    }
    
    static func resetAll() {
        do {
            try shared.container.managedObjectModel.entities.forEach { (entity) in
                if let name = entity.name {
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try shared.container.viewContext.execute(request)
                }
            }

            try shared.container.viewContext.save()
            print("RESET SUCCESS")
        } catch {
            print("error resetting the database: \(error.localizedDescription)")
        }
    }
}

extension NSManagedObjectContext {
    func saveObjects() {
        
        guard self.hasChanges else { return }

        for obj in self.insertedObjects {
            if let word = obj as? Word, word.content.count == 0 {
                print("Empty Word")
                self.delete(obj)
            }
            if let db = obj as? Database, db.name.count == 0 {
                print("Unnamed DB")
                self.delete(obj)
            }
            if let mode = obj as? GameMode, mode.name.count == 0 {
                print("Unnamed Mode")
                self.delete(obj)
            }
        }
        
        do {
            try self.save()
        } catch let error {
            print("Could not save context. \(error.localizedDescription)")
        }
    }
    
    func checkNewDBForConflict(name: String, type: DBType) -> Bool {

        let request = Database.fetchRequest()
        request.predicate = NSPredicate(format: "name_ == %@ AND type_ == %@", name.lowercased(), type.rawValue)
        
        let res = self.safeFetch(request)
        
        if res.count == 1 {
            Game.errorHandler.showAlert(title: "Database Already Exists", message: "Would you like to overwrite it?")
            return true
        }
        return false
    }
    func checkNewModeForConflict(name: String, type: GameType) -> Bool {
        
        let request = GameMode.fetchRequest()
        request.predicate = NSPredicate(format: "name_ == %@ AND gameType_ == %@", name.lowercased(), type.rawValue)
        
        let res = self.safeFetch(request)
        if res.count == 1 {
            Game.errorHandler.showAlert(title: "Mode Already Exists", message: "Would you like to overwrite it?")
            return true
        }
        return false
    }

    func safeFetch<T>(_ request: NSFetchRequest<T>) -> [T] where T : NSFetchRequestResult {
        do {
            return try self.fetch(request)
        } catch let error {
            Game.errorHandler.showBanner(title: "Could not fetch \(T.self) items", message: error.localizedDescription)
            print("Could not fetch the given request: \(request) \n\(error.localizedDescription)")
            return []
        }
    }
    
    func getUniqueWords(db: Database) -> Int {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Word")
        // Required! Unless you set the resultType to NSDictionaryResultType, distinct can't work.
        // All objects in the backing store are implicitly distinct, but two dictionaries can be duplicates.
        // Since you only want distinct names, only ask for the 'name' property.
        request.propertiesToFetch = ["variant_"]
        request.returnsDistinctResults = true
        request.resultType = NSFetchRequestResultType.dictionaryResultType
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@", db)
    
        // self.count(for: request) counts all values??
        return self.safeFetch(request).count
    }
    
    func getWords(db: Database) -> ([String:[String]], Int) {
        let request = Word.fetchRequest()
        request.predicate = NSPredicate(format: "databases_ CONTAINS %@", db)
    
        
        let variations = Dictionary(grouping: self.safeFetch(request)) { (element : Word)  in
            element.variant
        }
        .compactMap({
            $0.value
                .map({ $0.content })
        })
        
        var res: [String:[String]] = [:]
        
        for variants in variations {
            if variants.count == 1 {
                res[variants.first!] = [variants.first!]
            } else {
                for i in variants.indices {
                    let word = variants[i]
                    res[word] = variants
                }
            }
        }
        return (res, variations.count)
    }
}
