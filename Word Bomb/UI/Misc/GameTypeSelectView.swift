//
//  GameTypeSelect.swift
//  Word Bomb
//
//  Created by Brandon Thio on 10/7/21.
//

import SwiftUI

struct GameTypeSelectView: View {
    
    @Binding var gameType: GameType
    @Binding var viewToShow: ViewToShow
    
    var body: some View {
        
        VStack(spacing:100) {
            
            SelectGameTypeText()
            
            VStack(spacing: 50) {
                ForEach(GameType.allCases, id: \.self) { type in
                    Game.MainButton(label: type.rawValue.uppercased()) {
                        
                        withAnimation {
                            gameType = type
                            viewToShow = .modeSelect
                        }
                    }
                }
            }
            Game.BackButton {
                withAnimation { viewToShow = .main }
            }
        }
        .frame(width: Device.width, height: Device.height)
        .transition(.asymmetric(insertion: AnyTransition.move(edge: .trailing), removal: AnyTransition.move(edge: .leading)))
        .animation(Game.mainAnimation)
    }
}


struct SelectGameTypeText: View {
    
    var body: some View {
        
        Text("Select Game Type")
            .fontWeight(.bold)
            .font(.largeTitle)
        
    }
}


struct GameTypeSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        GameTypeSelectView(gameType: .constant(.Classic), viewToShow: .constant(.gameTypeSelect))
    }
}
