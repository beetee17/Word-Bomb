//
//  DatabaseView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 29/7/21.
//

import SwiftUI
import CoreData

struct DatabaseView: View {
    
    @Environment(\.editMode) var isEditing
    var db: Database
    @State private var filter = ""
    @State private var prefix: String?
    @State private var text = ""
    @State private var wordsToAdd = [String]()
    @State private var wordsToDelete = Set<Word>()

    
    var body: some View {
        
        VStack(spacing:15) {
            
            WordSearchBar(filter: $filter)

            ScrollView {
                
                LazyVStack {
                    
                    NewWordsView(wordsToAdd: $wordsToAdd)
                    
                    
                    FilteredList(db: db, filterKey: "content_",
                                 filterValue: filter,
                                 prefix: prefix,
                                 sortDescriptors: [NSSortDescriptor(keyPath: \Word.content_, ascending: true)]) { (word:Word) in
                        VStack {
                            HStack {
                                if isEditing?.wrappedValue == .active  {
                                    Image(systemName: wordsToDelete.contains(word) ? "checkmark.circle.fill" : "circle")
                                }
                                Text(word.content.capitalized)
                                    .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                                    .padding(.leading)
                                
                            }
                            Divider()
                        }
                        .onTapGesture {
                            if isEditing?.wrappedValue == .active { wordsToDelete.insert(word) }
                            
                        }
                    }
                }
            }
            .overlay(AlphabetScrollList(filter: $prefix))
            .navigationTitle(Text("Search"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    Button(action: {
                        withAnimation {
                            db.remove(wordsToDelete)
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                    
                    EditButton()
                }
                
            }
            .ignoresSafeArea(.all)
            .onDisappear() {
                saveChanges()
            }
        }
    }
    func saveChanges() {
        for word in wordsToAdd {
            let _ = Word(context: moc, content: word, db: db)
        }
        moc.saveObjects()
    }
}



struct FilteredList<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>
    
    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content
    
    var body: some View {
        ForEach(fetchRequest, id: \.self) { item in
            self.content(item)
        }
    }
    
    init(db: Database, filterKey: String, filterValue: String, prefix: String?, sortDescriptors: [NSSortDescriptor], @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors ,
                                        predicate: prefix == nil
                                        ? NSPredicate(format: "databases_ CONTAINS %@ AND %K LIKE %@", db, filterKey, "*\(filterValue.lowercased())*")
                                        : NSPredicate(format: "databases_ CONTAINS %@ AND %K BEGINSWITH %@ AND %K LIKE %@",
                                                      db, filterKey, prefix!.lowercased(), filterKey, "*\(filterValue.lowercased())*"))
        self.content = content
    }
}
