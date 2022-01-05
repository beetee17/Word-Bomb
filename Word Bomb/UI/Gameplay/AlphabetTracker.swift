//
//  AlphabetTracker.swift
//  Word Bomb
//
//  Created by Brandon Thio on 5/1/22.
//

import SwiftUI

struct AlphabetTracker: View {
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y", "Z"]
    var usedLetters: Set<String>
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text("USED LETTERS")
                    .boldText()
                
                Spacer()
                    .overlay(
                        Button(action: {
                            AudioPlayer.playSound(.Cancel)
                            isShowing = false
                        }) {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                                .padding(.trailing)
                            
                        }
                            .buttonStyle(ScaleEffect())
                    )
            }
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(alphabet, id: \.self) { letter in
                    Image(systemName: "\(letter.lowercased()).square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                        .opacity(usedLetters.contains(letter.lowercased()) ? 1 : 0.5)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .scaleEffect(isShowing ? 1 : 0)
        .opacity(isShowing ? 1 : 0)
        .animation(.interactiveSpring())
        
    }
}

struct AlphabetTracker_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color("Background")
                .blur(radius: 10)
                .ignoresSafeArea()
            AlphabetTracker(usedLetters: Set(["a", "c", "w", "o"]), isShowing: .constant(true))
        }
        
    }
}
