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
        
        let wordsPreview = Database(context: viewContext)
        wordsPreview.name = "words"
        
        let countriesPreview = Database(context: viewContext)
        countriesPreview.name = "countries"
        
        for type in GameType.allCases {
            
            let newMode = GameMode(context: viewContext, gameType: type, name: "Test Mode", instruction: "Test Instruction", wordsDB: wordsPreview, queriesDB: countriesPreview)
            
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
}
