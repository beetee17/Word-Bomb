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
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Image(systemName:"plus.circle.fill")
                        .foregroundColor(.green)
                    
                    TextField("New Entry", text: $newWord) { isEditing in } onCommit: {
                        if newWord.trim().count != 0 {
                            wordsToAdd.append(newWord)
                            newWord = ""
                        }
                    }
                    .padding(.vertical, 5)
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

//struct NewWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewWordsView(dbHandler: DatabaseHandler(db: Database(context: moc)))
//    }
//}
