//
//  ErrorViewModel.swift
//  Word Bomb
//
//  Created by Brandon Thio on 17/12/21.
//

import Foundation

/// View model that controls the display of pop-up and banner notifications
class ErrorViewModel: NSObject, ObservableObject {
    
    /// True if a pop-up notification should be shown to the user
    @Published var alertIsShown = false
    /// Title of the pop-up
    @Published var alertTitle = ""
    /// Contents of the pop-up
    @Published var alertMessage = ""
    
    /// True if a banner notification should be shown to the user
    @Published var bannerIsShown = false
    /// Title of the banner
    @Published var bannerTitle = ""
    /// Contents of the banner
    @Published var bannerMessage = ""
    
    /// Displays a pop-up notification
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - message: The message of the notification
    func showAlert(title: String, message: String) {
        AudioPlayer.playSound(.Alert)
        alertTitle = title
        alertMessage = message
        alertIsShown = true
    }
    
    /// Displays a banner-style notification
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - message: The message of the notification
    func showBanner(title: String, message: String) {
        AudioPlayer.playSound(.Banner)
        bannerTitle = title
        bannerMessage = message
        bannerIsShown = true
    }
}
