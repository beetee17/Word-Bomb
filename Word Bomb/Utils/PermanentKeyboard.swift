//
//  PermanentKeyboard.swift
//  Word Bomb
//
//  Created by Brandon Thio on 30/12/21.
//

import Foundation
import SwiftUI

// https://stackoverflow.com/questions/65545374/how-to-always-show-the-keyboard-in-swiftui
struct PermanentKeyboard: View {
    @Binding var text: String
    @Binding var forceResignFirstResponder: Bool
    
    var onCommitAction: () -> Void
    
    var body: some View {
        ZStack {
            // TODO: causing attribute graph warnings
            PermanentKeyboardUIView(text: $text, forceResignFirstResponder: $forceResignFirstResponder)
            
            Text(text)
                .opacity(text == "\n" ? 0 : 1)
                .onChange(of: text) { _ in
                    if text.last == "\n" {
                        print("COMMITTED TEXT \(text)")
                        onCommitAction()
                        text = ""
                    }

                }
                .ignoresSafeArea(.keyboard)
        }
    }
}

struct PermanentKeyboardUIView: UIViewRepresentable {
    @Binding var text: String
    @Binding var forceResignFirstResponder: Bool
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PermanentKeyboardUIView
        
        init(_ parent: PermanentKeyboardUIView) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            //Async to prevent updating state during view update
            DispatchQueue.main.async {
                
                if string != "" {
                    self.parent.text.append(string)
                    
                }
                
                //Allows backspace
                else {
                    self.parent.text.removeLast()
                }
            }
            
            return false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textfield = UITextField()
        textfield.delegate = context.coordinator
        
        // settings
        textfield.autocorrectionType = .no // this does not hide the predictive text toolbar
        textfield.textContentType = .newPassword // but this does
        textfield.autocapitalizationType = .words
        textfield.font = UIFont.systemFont(ofSize: 20)
        
        //Makes textfield invisible
        textfield.textColor = .clear
        
        return textfield
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        //Makes keyboard permanent
        if !forceResignFirstResponder && !uiView.isFirstResponder  {
            
            uiView.becomeFirstResponder()
        }
        else if forceResignFirstResponder {
            
            uiView.resignFirstResponder()
        }
        
        //Reduces space textfield takes up as much as possible
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
