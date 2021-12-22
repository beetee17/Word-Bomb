//
//  CoreDataViewModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 19/12/21.
//

import Foundation
import CoreData

class CoreDataViewModel: ObservableObject {

    @Published var setUpComplete = UserDefaults.standard.bool(forKey: "Set Up Complete") {
        didSet {
            UserDefaults.standard.set(setUpComplete, forKey: "Set Up Complete")
        }
    }
    @Published var progress: Float = 0
    @Published var status = "Getting things ready for the first time..."
    
    private var totalInitWords = Game.dictionary.count + Game.syllables.count + Game.countries.count
    
    func incrementProgress(value: Float) {
        DispatchQueue.main.async {
            self.progress += value
        }
    }
    func updateStatus(text: String) {
        DispatchQueue.main.async {
            self.status = text
        }
    }
    
    func initDatabases() {

        PersistenceController.shared.container.performBackgroundTask { moc in
            moc.mergePolicy = CustomMergePolicy()
            
            PersistenceController.resetAll()
            
            let countries = Database(context: moc,
                                     name: "countries",
                                     type: .words,
                                     isDefault: true)
            self.populateDB(context: moc, db: countries, words: Game.countries)
            
            
            let syllables = Database(context: moc,
                                     name: "syllables",
                                     type: .queries,
                                     isDefault: true)
            self.populateDB(context: moc, db: syllables, words: Game.syllables)
            
            let words = Database(context: moc,
                                 name: "words",
                                 type: .words,
                                 items: Game.dictionary,
                                 isDefault: true)
            self.populateDB(context: moc, db: words, words: Game.dictionary)
            
            self.updateStatus(text: "Just awhile more...")

            let _ = GameMode(context: moc, gameType: .Exact, name: "country", instruction: "NAME A COUNTRY", wordsDB: countries)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Reverse, name: "country", instruction: "COUNTRIES STARTING WITH", wordsDB: countries)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Classic, name: "words", instruction: "WORDS CONTAINING", wordsDB: words, queriesDB: syllables)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Reverse, name: "words", instruction: "WORDS STARTING WITH", wordsDB: words)
            self.incrementProgress(value: 0.05)

            moc.saveObjects()
            self.updateStatus(text: "Almost Done...")
            self.incrementProgress(value: 0.3)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.setUpComplete = true
            }
            
            
            print("Initialised Game Modes")
            
        }
    }
    func populateDB(context: NSManagedObjectContext, db: Database, words: [Any]) {

        if let queries = words as? [(String, Int)] {
            for (word, frequency) in queries {
                _ = Word(context: context, content: word, frequency: frequency, db: db)
                self.incrementProgress(value: 0.7/Float(totalInitWords))
            }
        }
        else if let items = words as? [[String]] {
            for variants in items {
                let variant = UUID()
                for word in variants {
                    _ = Word(context: context, content: word, variant: variant, db: db)
                    self.incrementProgress(value: 0.7/Float(totalInitWords))
                }
            }
        }
        moc.saveObjects()
        print("Initialised \(db.name) Database")
    }
}

