//
//  ChargeUpBar.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/1/22.
//

import SwiftUI

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
                    AudioPlayer.playSound(.Combo)
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
                        .frame(width: 10, height: Device.height*0.1)
                                        
                    Game.MainButton(label: "CHARGE") {
                        value += 50
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
