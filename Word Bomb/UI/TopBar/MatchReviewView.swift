//
//  MatchReviewView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct MatchReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var mode: GameMode
    var usedWords: Set<String>
    
    @State var totalWords: Int = 0
    @State private var filter = ""
    @State private var prefix: String?
    @State private var text = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing:15) {
                
                WordSearchBar(filter: $filter)
                
                ScrollView {
                    
                    LazyVStack {
                        
                        FilteredList(db: mode.wordsDB, filterKey: "content_",
                                     filterValue: filter,
                                     prefix: prefix,
                                     sortDescriptors: [NSSortDescriptor(keyPath: \Word.content_, ascending: true)]) { (word:Word) in
                            VStack {
                                HStack {
                                    Text(word.content.capitalized)
                                        .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                                        .padding(.leading)
                                        .foregroundColor(usedWords.contains(word.content) ? .green : .white)
                                    
                                }
                                Divider()
                            }
                        }
                    }
                }
                .overlay(AlphabetScrollList(filter: $prefix))
                .navigationTitle("Match Review: \(usedWords.count)/\(totalWords)")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(.all)
            }
            .onAppear() {
                totalWords = viewContext.getUniqueWords(db: mode.wordsDB)
            }
        }
    }
}




struct MatchReviewView_Previews: PreviewProvider {
    static var previews: some View {
        
        MatchReviewView(mode: .exampleDefault, usedWords: Set(["word2", "word3"]))
            .environment(\.managedObjectContext, moc_preview)
    }
}
