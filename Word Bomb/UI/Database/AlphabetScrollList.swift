//
//  AlphabetScrollList.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/8/21.
//

import SwiftUI

struct AlphabetScrollList: View {
    
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y", "Z"]

    @Binding var filter: String?
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
                ForEach(alphabet, id: \.self) { letter in
                    Button(letter) {
                        withAnimation {
                            filter = letter == filter
                                     ? nil
                                     : letter
                        }
                    }
                    .foregroundColor(.blue)
                    .frame(width: 22, height: 22) // for drawing of background
                    .background(filter == letter ? Color.gray.opacity(0.3) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
                    .frame(width: 75, height: 25) // button tappable region
                }
            }
        }
    }
}


//struct AlphabetScrollList_Previews: PreviewProvider {
//    static var previews: some View {
//        AlphabetScrollList(dbHandler: DatabaseHandler(db: Database(context: moc)))
//    }
//}
