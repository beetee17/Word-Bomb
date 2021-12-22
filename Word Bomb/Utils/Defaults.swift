//
//  Defaults.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/7/21.
//

import Foundation
import SwiftUI

struct Device {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
}


struct Game {
    
    static var viewModel = WordBombGameViewModel()
    static var errorHandler = ErrorViewModel()
    
    static let countries = loadWords("countries")
    static let dictionary = loadWords("words")
    static let syllables = loadSyllables("syllables_2")
    
    static let playerAvatarSize = Device.width/3.5
    
    static let bombSize = Device.width*0.4
    
    static let miniBombSize = Device.width*0.2
    
    static let miniBombExplosionOffset = CGFloat(10.0)
    
    static let explosionDuration = 0.8
    
    static var timer: Timer? = nil
    
    static func stopTimer() {
        Game.timer?.invalidate()
        Game.timer = nil
        print("Timer stopped")
    }
    
    static let mainAnimation = Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
    static func mainButton(label: String, systemImageName: String? = nil, image: AnyView? = nil, action: @escaping () -> Void) -> some View {
        
        precondition(systemImageName != nil || image != nil)
        
        return Button(action: action) {
            HStack {
                if let systemName = systemImageName {
                    Image(systemName: systemName)
                }
                else if let image = image {
                    image
                }
                Text(label)
                    
            }
        }
        .buttonStyle(MainButtonStyle())
    }
    
    static func backButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "arrow.backward")
                .font(Font.title.bold())
                .foregroundColor(.white)
        }
    }
}
