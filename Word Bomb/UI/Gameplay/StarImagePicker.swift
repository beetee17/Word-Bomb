//
//  StarImagePicker.swift
//  Word Bomb
//
//  Created by Brandon Thio on 3/1/22.
//

import Foundation

class StarImagePicker: ObservableObject {
    @Published var imageName = "star-happy0"
    @Published var state: State = .Happy
    
    enum State: String {
        case Happy = "star-happy"
        case Sad = "star-sad"
        case Combo = "star-combo"
    }
    
    func getImage(for state: State) {
        self.state = state
        
        var imageNum: Int
        
        switch state {
        case .Happy:
            imageNum = Int.random(in: 0...5)
        case .Sad:
            imageNum = Int.random(in: 0...5)
        case .Combo:
            imageNum = Int.random(in: 0...3)
        }
        
        self.imageName = state.rawValue + "\(imageNum)"
    }
}
