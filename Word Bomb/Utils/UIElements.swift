//
//  MainButton.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import SwiftUI

// MARK: Default UI Elements
extension Game {
    
    static let mainAnimation = Animation.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)
    
    struct MainButton: View {
        var label: String
        var systemImageName: String?
        var image: AnyView? = nil
        var sound: Sound
        var action: () -> Void
        
        init(label: String, systemImageName: String? = nil, image: AnyView? = nil, sound: Sound = .Select, action: @escaping () -> Void) {
            self.label = label
            self.systemImageName = systemImageName
            self.image = image
            self.sound = sound
            self.action = action
        }
        
        var body: some View {
            Button(action: {
                AudioPlayer.playSound(sound)
                action()
            }) {
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
    }
    
    struct BackButton: View {
        
        var action: () -> Void
        
        var body: some View {
            Button(action: {
                AudioPlayer.playSound(.Cancel)
                action()
            }) {
                Image(systemName: "arrow.backward")
                    .font(Font.title.bold())
                    .foregroundColor(.white)
            }
        }
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing:50) {
            Game.MainButton(label: "click me", systemImageName: "arrow.right", action: {})
            Game.BackButton(action: {})
        }
    }
}
