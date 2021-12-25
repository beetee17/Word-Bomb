//
//  NewWordsView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/8/21.
//

import SwiftUI

struct NewWordsView: View {
    
    @Binding var wordsToAdd: [String]
    @State private var newWord: String = ""
    @State private var forceResignKeyboard = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName:"plus.circle.fill")
                        .foregroundColor(.green)
                        .padding(.leading, 15)
                    
                    PermanentKeyboard(text: $newWord, forceResignFirstResponder: $forceResignKeyboard) {
                        
                        if newWord.trim().count != 0 {
                            wordsToAdd.append(newWord.trim())
                            
                        } else {
                            forceResignKeyboard = true
                        }
                        
                    }
                    .padding(.vertical, 5)
                    
                    Spacer()
                }
                .onTapGesture {
                    forceResignKeyboard = false
                }
                
                Divider()
                
                ForEach($wordsToAdd, id: \.self) { word in
                    Text(word.wrappedValue.capitalized)
                        .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                        .padding(.leading)
                    Divider()
                }
                .onDelete { offsets in
                    wordsToAdd.remove(atOffsets: offsets)
                }
                
            }
            
        }
    }
}

struct NewWordsView_Previews: PreviewProvider {
    
    struct NewWordsView_Harness: View {
        
        @State private var wordsToAdd: [String] = ["Test"]
        
        var body: some View {
            NewWordsView(wordsToAdd: $wordsToAdd)
        }
    }
    
    static var previews: some View {
        NewWordsView_Harness()
    }
}
