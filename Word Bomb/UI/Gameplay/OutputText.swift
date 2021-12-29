//
//  OutputText.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI

struct OutputText: View {
    
    @Binding var text: String
    
    var body: some View {
        
        ZStack {
            Text("INVISIBLE PLACEHOLDER TEXT")
                .font(.system(size: 20, weight: .bold, design: .default))
                .textCase(.uppercase)
                .opacity(0)
            
            let output = text.trim().lowercased()
            
            Text(output)
                .font(.system(size: 20, weight: .bold, design: .default))
                .textCase(.uppercase)
                .foregroundColor(isCorrect(output) ? .green : .red)
                .lineLimit(1)
                .transition(AnyTransition.scale.animation(.easeInOut(duration:0.3)))
                .id(output)
                .onChange(of: output, perform: { newOutput in
                    if isCorrect(newOutput) { Game.playSound(file: "correct") }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1,
                                                  execute: { self.clearOutput(newOutput) })
                })
        }
    }
    
    func isCorrect(_ output: String) -> Bool {
        return output.contains("correct")
    }
    
    /// Clears the output text
    /// - Parameter newOutput: The current output text as reflected in the UI. This is needed for concurrency purposes - to check if the output is the same as current to avoid clearing of new outputs
    func clearOutput(_ newOutput: String) {
        if newOutput == text.trim().lowercased() { text = "" }
    }
}


struct OutputText_Previews: PreviewProvider {
    
    struct OutputText_Harness: View {
        
        @State private var text = ""
        
        var body: some View {
            VStack {
                Game.mainButton(label: "Generate Correct Output") {
                    text = "input is correct!"
                }
                Game.mainButton(label: "Generate Wrong Output") {
                    text = "input is wrong!"
                }
                OutputText(text: $text)
            }
        }
    }
    
    static var previews: some View {
        OutputText_Harness()
    }
}
