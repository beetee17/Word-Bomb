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
    var value: Int
    var invert: Bool
    
    var body: some View {
        
        HStack {
            //            Image(systemName: "star.fill")
            //                .resizable()
            //                .frame(width:40, height:40)
            //                .scaledToFit()
            //                .offset(x: 20)
            //                .zIndex(1)
            //                .foregroundColor(.yellow)
           
            
            GeometryReader { geometry in
                
                let width = invert
                ? geometry.size.width
                : min(CGFloat(Float(value)/50) * geometry.size.width, geometry.size.width)
                let height = invert
                ? min(CGFloat(Float(value)/50)*geometry.size.height, geometry.size.height)
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
                
            }
        }
    }
}

struct ChargeUpBar_Previews: PreviewProvider {
    struct ChargeUpBar_Harness: View {
        @State private var value = 5
        var body: some View {
            ZStack {
                Color("Background")
                VStack {
                    ChargeUpBar(value: value, invert: true)
                        .frame(width: 30, height: 300)
                                        
                    Game.MainButton(label: "CHARGE") {
                        value += 5
                    }
                    Game.MainButton(label: "RESET") {
                        value = 0
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
