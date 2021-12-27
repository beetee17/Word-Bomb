//
//  MatchProgressView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 27/12/21.
//

import SwiftUI

struct MatchProgressView: View {
    
    var usedWords: [String]
    @Binding var showMatchProgress: Bool
    
    init(usedWords: [String]?, showMatchProgress: Binding<Bool>) {
        self.usedWords = usedWords ?? []
        _showMatchProgress = showMatchProgress
        
        // the only working way to make background clear
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("USED WORDS")
                    .boldText()
                Spacer()
                Image(systemName: "xmark.circle")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        showMatchProgress.toggle()
                    }
            }
            List(usedWords, id: \.self) { word in
                Text(word.capitalized)
                    .frame(maxWidth: Device.width, maxHeight: 20, alignment:.leading)
                    .padding(.leading)
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
    }
    
}

struct MatchProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MatchProgressView(usedWords: (1...100).map({"Word \($0)"}), showMatchProgress: .constant(true))
    }
}
