//
//  RotatingBomb.swift
//  Word Bomb
//
//  Created by Brandon Thio on 4/1/22.
//

import SwiftUI

struct RotatingBomb: View {
    @Binding var isRotating: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing:-10) {
                Image("word1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                Image("bomb1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
            }
            Image("bomb-icon")
                .resizable()
                .scaledToFit()
                .frame(width: 210)
                .rotationEffect(Angle(degrees: isRotating ? -10 : 5))
                .offset(x:-40 , y: 25)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true))
        }
        .scaleEffect(1.1)
    }
}

struct RotatingBomb_Previews: PreviewProvider {
    struct RotatingBomb_Harness: View {
        @State var isRotating = false
        var body: some View {
            RotatingBomb(isRotating: $isRotating)
                .onAppear { isRotating = true }
        }
    }
    static var previews: some View {
        RotatingBomb_Harness()
    }
}
