//
//  LoadingText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 28/12/21.
//

import SwiftUI

struct LoadingText: View {
    var text: String
    @State var ellipses = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("\(text)\(ellipses)")
            .transition(.slide)
            .onReceive(timer) { _ in
                if ellipses.count == 3 {
                    ellipses = ""
                } else {
                    ellipses += "."
                }
            }
            .onAppear() {
                ellipses = "."
            }
    }
}

struct LoadingText_Previews: PreviewProvider {
    static var previews: some View {
        LoadingText(text: "Loading")
    }
}
