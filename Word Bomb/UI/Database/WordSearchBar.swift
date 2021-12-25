//
//  WordSearchBar.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/8/21.
//

import SwiftUI

struct WordSearchBar: View {

    @Binding var filter: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            
            TextField("Search", text: $filter)
                .foregroundColor(.primary)
            
            Button(action: {
                filter = ""
                
            }) {
                Image(systemName: "xmark.circle.fill").opacity(filter == "" ? 0 : 1)
            }
        }
        .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
    }
}

struct WordSearchBar_Previews: PreviewProvider {
    
    struct WordSearchBar_Harness: View {
        
        @State private var filter = ""
        
        var body: some View {
            WordSearchBar(filter: $filter)
        }
    }
    
    static var previews: some View {
        WordSearchBar_Harness()
    }
}
