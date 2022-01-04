//
//  ChargeUpBar.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/1/22.
//

import SwiftUI
struct Shimmer: View {
    var delay: Double
    @State var show = false
    @Binding var width: CGFloat
    @Binding var height: CGFloat
    
    var body: some View {
        Rectangle()
            .frame(width: width, height: height)
            .foregroundColor(.yellow)
            .mask(
                Capsule()
                    .fill(LinearGradient(gradient: .init(colors: [.clear, .white, .clear]), startPoint: .top, endPoint: .bottom))
                    .frame(width: width, height: height)
                    .opacity(0.5)
                    .rotationEffect(Angle(degrees: 15))
                    .offset(x: show ? width : -2*width)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 3).delay(delay).repeatForever(autoreverses: false)) {
                    show.toggle()
                    print("SHIMMERING")
                }
            }
    }
}

struct ChargeUpBar: View {
    
    @ObservedObject var imagePicker: StarImagePicker
    var value: Int
    var multiplier: Int
    var invert: Bool
    
    var body: some View {
        
        VStack {

            let val = Float(value)/Float(Game.getMaxCharge(for: multiplier))
            
            GeometryReader { geometry in
                
                                             
                let width = invert
                ? geometry.size.width
                : min(CGFloat(val) * geometry.size.width, geometry.size.width)
                
                let height = invert
                ? min(CGFloat(val) * geometry.size.height, geometry.size.height)
                : geometry.size.height
                
                let widthBinding = Binding(
                    get: { width },
                    set: {_ in }
                )
                let heightBinding = Binding(
                    get: { height },
                    set: {_ in }
                )
                
                ZStack(alignment: invert ? .bottom : .leading) {
                    RoundedRectangle(cornerRadius: 45)
                        .frame(width: geometry.size.width , height: geometry.size.height)
                        .innerShadow(using: RoundedRectangle(cornerRadius: 45))
                        .opacity(0.3)
                        .foregroundColor(.yellow)
                    
                    Rectangle()
                        .frame(width: width, height: height)
                        .overlay(LinearGradient(colors: [.orange, .yellow], startPoint: .bottom, endPoint: .top))
                        .animation(.linear)
                    
                    Shimmer(delay: 0, width: widthBinding, height: heightBinding)
                    
                    RoundedRectangle(cornerRadius: 45)
                        .stroke(lineWidth: 5)
                        .foregroundColor(.black)

                    
                }
                .cornerRadius(45)
                
                if multiplier > 1 {
                    Image(multiplier == 2 ? "x2" : "x3")
                        .resizable()
                        .scaledToFit()
                        .frame(width: invert ? geometry.size.width*2.5 : geometry.size.height)
                        .pulseEffect()
                        .rotationEffect(Angle(degrees: 15))
                        .shadow(radius: 5)
                        .if(invert) { $0.offset(x: -8,
                                                y: geometry.size.height*0.9) }
                        .if(!invert) { $0.offset(x: -5, y: 5) }  
                }
            }
            .onChange(of: multiplier) { [multiplier] newValue in
                if newValue > multiplier {
                    imagePicker.getImage(for: .Combo)
                }
            }
        }
    }
}

struct ChargeUpBar_Previews: PreviewProvider {
    struct ChargeUpBar_Harness: View {
        @State private var value = 5
        @State private var multiplier = 1
        var body: some View {
            ZStack {
                Color("Background")
                VStack {
                    ChargeUpBar(
                        imagePicker: StarImagePicker(),
                        value: value,
                        multiplier: multiplier,
                        invert: true)
                        .frame(width: 10, height: 100)
                                        
                    Game.MainButton(label: "CHARGE") {
                        value += 5
                    }
                    Game.MainButton(label: "MULTIPLY") {
                        withAnimation(.easeInOut) {
                        multiplier += 1
                        }
                    }
                    Game.MainButton(label: "RESET") {
                        value = 0
                        multiplier = 1
                    }
                    
                }
            }
            
        }
    }
    static var previews: some View {
        ChargeUpBar_Harness()
    }
}
extension View {
    func innerShadow<S: Shape>(using shape: S, angle: Angle = .degrees(0), color: Color = .black, width: CGFloat = 9, blur: CGFloat = 5) -> some View {
        let finalX = CGFloat(cos(angle.radians - .pi / 2))
        let finalY = CGFloat(sin(angle.radians - .pi / 2))
        return self
            .overlay(
                shape
                    .stroke(color, lineWidth: width)
                    .offset(x: finalX * width * 0.6, y: finalY * width * 0.6)
                    .blur(radius: blur)
                    .mask(shape)
            )
    }
}
