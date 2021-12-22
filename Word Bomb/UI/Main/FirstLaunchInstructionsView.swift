//
//  FirstLaunchInstructionsView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 28/7/21.
//

import SwiftUI

struct FirstLaunchInstructionsView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.8)
                .ignoresSafeArea()
                
            HelpButton(action: { }, border: true)
                
                .ignoresSafeArea()
 
            VStack(spacing: 50) {
                Text("Welcome to Word Bomb!")
                    .font(.system(.title, design: .monospaced).bold())
                    .textCase(.uppercase)
                
                Text("Click on the help button at the top right whenever you need it!\n\nTap anywhere to dismiss.")
                    .font(.system(.title3, design: .monospaced))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 15)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct FirstLaunchInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        FirstLaunchInstructionsView()
    }
}
