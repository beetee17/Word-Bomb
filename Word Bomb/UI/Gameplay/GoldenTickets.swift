//
//  GoldenTickets.swift
//  Word Bomb
//
//  Created by Brandon Thio on 7/1/22.
//

import SwiftUI

struct GoldenTickets: View {
    var numTickets: Int
    var claimAction: () -> Void
    var body: some View {
        
        HStack(spacing: -30) {
            ForEach(0..<numTickets, id: \.self) { i in
                Button(action: claimAction) {
                    Image("Golden Ticket")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .rotationEffect(Angle(degrees: 55))
                        .zIndex(Double(i))
                        .shadow(color: .black.opacity(0.7), radius: 5)
                        
                }
                
                .transition(.scale(scale: 2).combined(with: .opacity))
                
            }
        }.animation(.easeInOut(duration: 0.8))
    }
}

struct GoldenTickets_Previews: PreviewProvider {
    struct GoldenTickets_Harness: View {
        @State private var numTickets = 5
        
        var body: some View {
            ZStack {
                Color("Background")
                GoldenTickets(numTickets: numTickets, claimAction: {
                    numTickets -= 1
                    AudioPlayer.playSound(.Combo)
                    
                })
            }
        }
    }
    static var previews: some View {
        GoldenTickets_Harness()
    }
}
