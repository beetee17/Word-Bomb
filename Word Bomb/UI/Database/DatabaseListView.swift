//
//  DatabaseListView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/8/21.
//

import SwiftUI
import CoreData



struct DatabaseListView: View {
    @ObservedObject var errorHandler = Game.errorHandler
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Database.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)],
                  predicate: NSPredicate(format: "type_ == %@", DBType.Words.rawValue)) var wordsDBs: FetchedResults<Database>
    
    @FetchRequest(entity: Database.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Database.name_, ascending: true)],
                  predicate: NSPredicate(format: "type_ == %@", DBType.Queries.rawValue)) var queriesDBs: FetchedResults<Database>
    
    @State var presentAddDBSheet = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Words")) {
                    DatabaseList(databases: wordsDBs)
                }
                Section(header: Text("Queries")) {
                    DatabaseList(databases: queriesDBs)
                }
            }
            .navigationTitle(Text("Databases"))
            .sheet(isPresented: $presentAddDBSheet, content: {
                AddDatabaseView()
                    .environment(\.managedObjectContext, viewContext)
                
            })
        }
        .banner(isPresented: $errorHandler.bannerIsShown, title: errorHandler.bannerTitle, message: errorHandler.bannerMessage)
    }
}

struct DatabaseList: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    var databases: FetchedResults<Database>
    
    func deleteDB(at offsets: IndexSet) {
        
        for index in offsets {
            let db = databases[index]
            guard !db.isDefault_ else {
                Game.errorHandler.showBanner(title: "Deletion Prohibited", message: "Cannot delete a default database!")
                return
            }
            let request = GameMode.fetchRequest()
            request.predicate = NSPredicate(format: "wordsDB_ == %@ OR queriesDB_ == %@", db, db)
            
            // TODO: alert user that deleting the database will also delete the following game modes
            viewContext.delete(db)
            
            let gameModesToDelete = viewContext.safeFetch(request)
            
            for mode in gameModesToDelete {
                viewContext.delete(mode)
            }
            
            
        }
        viewContext.saveObjects()
    }
    
    func duplicateDB(_ db: Database) {
        let _ = Database(context: viewContext,
                         name: "\(db.name) Copy",
                         db: db)
        
        viewContext.saveObjects()
    }
    
    var body: some View {
        
        ForEach(databases, id:\.self) { db in
            NavigationLink(
                destination: DatabaseView(db: db),
                label: {
                    Text("\(db.name.capitalized)")
                })
            
        }
        .onDelete(perform: { offsets in deleteDB(at: offsets) })
    }
}

struct DatabaseListView_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseListView()
            .environment(\.managedObjectContext, moc_preview)
    }
}
