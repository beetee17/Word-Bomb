//
//  MatchReviewView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct MatchReviewView: View {
    var words: [String]
    var usedWords: Set<String>
    var usedWordsArray: [String]
    var numCorrect: Int
    var totalWords: Int
    
    @State private var filter = ""
    @State private var text = ""
    
    init(words: [String]?, usedWords: Set<String>?, numCorrect: Int, totalWords: Int) {
        self.words = words ?? []
        self.usedWords = usedWords ?? Set()
        self.numCorrect = numCorrect
        self.totalWords = totalWords
        self.usedWordsArray = self.usedWords.sorted()
    }
    
    private func filtered(_ words: [String]) -> [String] {
        let filter = filter.trim().lowercased()
        return filter.isEmpty ? words : words.filter({ $0.contains(filter) })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing:15) {
                
                WordSearchBar(filter: $filter)
                
                ScrollView {
                    
                    LazyVStack {
                        ForEach(filtered(usedWordsArray), id: \.self) { word in
                            VStack {
                                HStack {
                                    Text(word.capitalized)
                                        .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                                        .padding(.leading)
                                        .foregroundColor(.green)
                                }
                                Divider()
                            }
                        }
                        
                        ForEach(filtered(words), id: \.self) { word in
                            if !usedWords.contains(word) {
                                VStack {
                                    HStack {
                                        Text(word.capitalized)
                                            .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                                            .padding(.leading)
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Match Review: \(usedWords.count)/\(totalWords)")
                .navigationBarTitleDisplayMode(.inline)
                .ignoresSafeArea(.all)
            }
        }
    }
}




struct MatchReviewView_Previews: PreviewProvider {
    static var previews: some View {
        MatchReviewView(words: ["Word1", "Word2", "Word3", "Word4"], usedWords: Set(["Word2", "Word1"]), numCorrect: 2, totalWords: 4)
    }
}
