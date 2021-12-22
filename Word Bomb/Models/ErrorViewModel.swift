//
//  ErrorViewModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/12/21.
//

import Foundation

class ErrorViewModel: NSObject, ObservableObject {
    
    @Published var alertIsShown = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    @Published var bannerIsShown = false
    @Published var bannerTitle = ""
    @Published var bannerMessage = ""
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        alertIsShown = true
    }
    
    func showBanner(title: String, message: String) {
        bannerTitle = title
        bannerMessage = message
        bannerIsShown = true
    }
}
