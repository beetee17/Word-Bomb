//
//  Logo.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI

struct LogoView: View {
    
    var body: some View {
        
        Image("logo-bomb-no-shadow")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 794/2, height: 511/2)
            .shadow(color: .black, radius: 0, x: 5, y: 5)
            .ignoresSafeArea(.all)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
