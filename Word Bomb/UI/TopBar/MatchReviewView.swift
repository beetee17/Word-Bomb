//
//  MatchReviewView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct MatchReviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    var mode: GameMode
    var words: [String]
    var usedWords: Set<String>
    
    var totalWords: Int
    @State private var filter = ""
    @State private var prefix: String?
    @State private var text = ""
    
    init(words: [String]?, usedWords: Set<String>?, totalWords: Int) {
        self.words = words ?? []
        self.usedWords = usedWords ?? Set()
        self.totalWords = totalWords
    }
    var filteredWords: [String] {
        prefix != nil
        ? (filter.trim().count == 0 ? words.filter({ $0.starts(with: prefix!) }) : words.filter({ $0.starts(with: prefix!) && $0.contains(filter.trim().lowercased()) }))
        : (filter.trim().count == 0 ? words : words.filter({ $0.contains(filter.trim().lowercased()) }))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing:15) {
                
                WordSearchBar(filter: $filter)
                
                ScrollView {
                    
                    LazyVStack {
                        // TODO: starts with prefix if prefix is non-nil
                        ForEach(filteredWords, id: \.self) { word in
                            VStack {
                                HStack {
                                    Text(word.capitalized)
                                        .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                                        .padding(.leading)
                                        .foregroundColor(usedWords.contains(word) ? .green : .white)
                                    
                                }
                                Divider()
                            }
                        }
//                        FilteredList(db: mode.wordsDB, filterKey: "content_",
//                                     filterValue: filter,
//                                     prefix: prefix,
//                                     sortDescriptors: [NSSortDescriptor(keyPath: \Word.content_, ascending: true)]) { (word:Word) in
//                            VStack {
//                                HStack {
//                                    Text(word.content.capitalized)
//                                        .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
//                                        .padding(.leading)
//                                        .foregroundColor(usedWords.contains(word.content) ? .green : .white)
//
//                                }
//                                Divider()
//                            }
//                        }
                    }
                }
                .overlay(AlphabetScrollList(filter: $prefix))
                .navigationTitle("Match Review: \(usedWords.count)/\(totalWords)")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(.all)
            }
//            .onAppear() {
//                totalWords = viewContext.getUniqueWords(db: mode.wordsDB)
//            }
        }
    }
}




//struct MatchReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        MatchReviewView(mode: .exampleDefault, usedWords: Set(["word2", "word3"]))
//            .environment(\.managedObjectContext, moc_preview)
//    }
//}
