//
//  Styles.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    let width = Device.width/2
    let height = Device.height*0.07
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .textCase(.uppercase)
            .font(Font.title2.bold())
            .frame(width: width, height: height)
            .padding(.horizontal)
            .lineLimit(1).minimumScaleFactor(0.5)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .circular))
    }
}
struct DonateButtonStyle: ButtonStyle {
    let width = 60.0
    let height = 30.0
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .font(.body.bold())
            .foregroundColor(.blue)
            .frame(width: width, height: height)
            .background(configuration.isPressed ? Color.gray.opacity(0.3) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .circular))
            .padding(.trailing, 15)
 
    }
}

extension Text {
    func boldText() -> some View {
        self
            .font(.title)
            .fontWeight(.bold)
            .textCase(.uppercase)
    }
}

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                }
                else {
                    source.wrappedValue = newValue
                }
        })
    }
}

// Permanent Keyboard
// https://stackoverflow.com/questions/65545374/how-to-always-show-the-keyboard-in-swiftui
struct PermanentKeyboard: View {
    @Binding var text: String
    @Binding var forceResignFirstResponder: Bool
    
    var onCommitAction: () -> Void
    
    var body: some View {
        ZStack {
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
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .words
        textfield.font = UIFont.systemFont(ofSize: 20)
        
        //Makes textfield invisible
        textfield.textColor = .clear
        
        return textfield
    }
    
    mutating func forceHideKeyboard() {
        forceResignFirstResponder = true
        print(forceResignFirstResponder)
        
    }
    
    
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        //Makes keyboard permanent
        if !uiView.isFirstResponder && !forceResignFirstResponder {
            
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

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}

extension View {
    func useScrollView(when condition: Bool) -> AnyView {
        if condition {
            print("condition \(condition)")
            return AnyView(
                ScrollView() {
                    self
                }
            )
        } else {
            return AnyView(self)
        }
    }
    func helpButton() -> some View {
        self.modifier(HelpSheet())
    }
    
}
// Conditional Modifier
// Text("some Text").if(modifierEnabled) { $0.foregroundColor(.Red) }
public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}






#if canImport(UIKit)
// To force SwiftUI to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func showKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
