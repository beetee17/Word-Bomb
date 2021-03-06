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

struct ScaleEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
    }
}

struct AnimatingIncrement: ViewModifier {
    var increment: Int
    var isAnimating: Bool
    var xOffset: Float
    
    func body(content: Content) -> some View {
         
        
            content
                .overlay(
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .scaledToFit()
                        Text("\(increment)")
                            .boldText()
                            .fixedSize(horizontal: false, vertical: false) // prevents text from getting truncated to ...
                    }
                        .frame(width: 150, height: 150)
                        .foregroundColor(.green)
                        .offset(x: CGFloat(xOffset), y: isAnimating ? -30 : -20)
                        .animation(.easeIn.speed(0.7))
                        .opacity(isAnimating ? 0.7 : 0)
                        .animation(.easeInOut.speed(0.7))
            )

    }
}
extension View {
    func animatingIncrement(_ increment: Int, isAnimating: Bool, xOffset: Float = 20) -> some View {
        self.modifier(AnimatingIncrement(increment: increment, isAnimating: isAnimating, xOffset: xOffset))
    }
}

struct PulseEffect: ViewModifier {

    @State var isOn = false
    var animation = Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(self.isOn ? 1 : 0.9)
            .opacity(self.isOn ? 1 : 0.8)
            .animation(animation, value: isOn)
            .onAppear {
                self.isOn = true
            }
    }
}

struct BounceEffect: ViewModifier {
    @State var animating = false
    var animation = Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)
    
    func body(content: Content) -> some View {
        content
            .offset(x: 0, y: animating ? -50 : 0)
            .animation(animation, value: animating)
            .onAppear() {
                animating = true
            }
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
            .font(.title2)
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
    func helpButton(action: @escaping () -> Void = {}) -> some View {
        self.modifier(HelpSheet(action: action))
    }
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
    func pulseEffect() -> some View  {
        self.modifier(PulseEffect())
    }
    func bounceEffect() -> some View  {
        self.modifier(BounceEffect())
    }
}

// Conditional Modifier
// Text("some Text").if(modifierEnabled) { $0.foregroundColor(.Red) }
extension View {
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
