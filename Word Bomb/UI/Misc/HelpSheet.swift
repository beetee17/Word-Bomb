//
//  HelpSheet.swift
//  Word Bomb
//
//  Created by Brandon Thio on 22/7/21.
//

import SwiftUI

struct HelpSheett: View {
    @State private var showHelpSheet = false
    var title: String
    var headers: [String]
    var content: [String]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    print("HELP")
                    showHelpSheet = true}) {
                    Image(systemName: "info.circle")
                        
                        .foregroundColor(.white)
                        .frame(width: 75, height: 75, alignment:.center) // tappable area
                        .sheet(isPresented: $showHelpSheet) {
                            NavigationView {
                                List {
                                    ForEach(Array(zip(self.headers, self.content)), id: \.0) { item in
                                        Section(header: Text(item.0)) {
                                            Text(item.1).foregroundColor(.white)
                                        }
                                    }
                                }
                                .navigationBarTitle(Text(title))
                                .listStyle(GroupedListStyle())
                                
                            }
                        
                        }
                        
                    }
            }
            Spacer()
        }
    }
}

struct HelpSheett_Previews: PreviewProvider {
    static var previews: some View {
        HelpSheett(title: "Preview", headers: ["Some header"], content: ["Some content"])
    }
}
