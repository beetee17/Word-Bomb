//
//  CoreDataViewModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 19/12/21.
//

import Foundation
import CoreData

/// View model that controls the setting up of the Core Data environment, and is the source of truth for `LoadingView`
class CoreDataViewModel: ObservableObject {
    
    /// True once all Core Data objects have been initialised successfully
    /// Remains true from then onwards via `UserDefaults` since the set-up process is only required once
    /// The boolean is handled in this way since `UserDefaults.standard.bool(forKey:)` returns false if value is not found (occurs on first launch of game)
    @Published var setUpComplete = UserDefaults.standard.bool(forKey: "Set Up Completed") {
        didSet {
            UserDefaults.standard.set(setUpComplete, forKey: "Set Up Completed")
        }
    }
    /// Estimation of current progress made in the setting up process (maximum of 1.0). Used for updating of `ProgressBar`.
    @Published var progress: Float = 0
    
    /// Message to be displayed to user concerning current status of the set-up process.
    @Published var status = "Getting things ready for the first time"
    
    /// Total number of words to be initialised in the set-up process; used to estimate the progress made in creating each word.
    private var totalInitWords = Game.dictionary.count + Game.syllables.count + Game.countries.count
    
    /// Increments the progress value to be reflected in `ProgressBar`
    /// - Parameter value: Float to be added to the current progress
    func incrementProgress(value: Float) {
        DispatchQueue.main.async {
            self.progress += value
        }
    }
    
    /// Updates the status to be reflected in `LoadingView`
    /// - Parameter text: String to update the current status with
    func updateStatus(text: String) {
        DispatchQueue.main.async {
            self.status = text
        }
    }
    
    /// Initialises all the necessary Core Data objects
    func initDatabases() {

        PersistenceController.shared.container.performBackgroundTask { moc in
            
            // Done in the background to avoid freezing UI
            // moc is a fresh instance of NSManagedContext, its mergePolicy will default to .error
            moc.mergePolicy = CustomMergePolicy()
            
            PersistenceController.resetAll()
            
            let countries = Database(context: moc,
                                     name: "countries",
                                     type: .Words,
                                     isDefault: true)
            self.populateDB(context: moc, db: countries, words: Game.countries)
            
            
            let syllables = Database(context: moc,
                                     name: "syllables",
                                     type: .Queries,
                                     isDefault: true)
            self.populateDB(context: moc, db: syllables, words: Game.syllables)
            
            let words = Database(context: moc,
                                 name: "words",
                                 type: .Words,
                                 isDefault: true)
            self.populateDB(context: moc, db: words, words: Game.dictionary)
            
            self.updateStatus(text: "Just awhile more")

            let _ = GameMode(context: moc, gameType: .Exact, name: "country", instruction: "NAME A COUNTRY", wordsDB: countries, isDefault: true)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Reverse, name: "country", instruction: "COUNTRIES STARTING WITH", wordsDB: countries, isDefault: true)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Classic, name: "words", instruction: "WORDS CONTAINING", wordsDB: words, queriesDB: syllables, isDefault: true)
            self.incrementProgress(value: 0.05)
            
            let _ = GameMode(context: moc, gameType: .Reverse, name: "words", instruction: "WORDS STARTING WITH", wordsDB: words, isDefault: true)
            self.incrementProgress(value: 0.05)

            moc.saveObjects()
            self.updateStatus(text: "Almost Done")
            self.incrementProgress(value: 0.3)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.setUpComplete = true
            }
            
            
            print("Initialised Game Modes")
            
        }
    }

    /// Adds words to the database
    /// - Parameters:
    ///   - context: `NSManagedObjectContext` to perform this Core Data task
    ///   - db: `Database` that will be added to
    ///   - words: Array representing `Word` objects that will be added to `db`.
    ///   If `words` is an array of `[String]`, then each element represents variants (different spellings) of the same word
    ///   If `words` is an array of `(String, Int)`, then each element represents a word with content of $0 and frequency of $1
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
        context.saveObjects()
        
        print("Initialised \(db.name) Database")
    }
}

