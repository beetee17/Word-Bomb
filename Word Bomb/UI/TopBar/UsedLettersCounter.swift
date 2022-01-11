//
//  UsedLettersCounter.swift
//  Word Bomb
//
//  Created by Brandon Thio on 11/1/22.
//

import SwiftUI

struct UsedLettersCounter: View {
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var usedLetters: Set<String>
    @Binding var showUsedLetters: Bool
    @State private var showRewards = false

    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y", "Z"]
    
    var body: some View {
        let usedLettersArray = usedLetters.sorted().map({ $0.uppercased() })
        
        let letterToShow = alphabet.first(where: { !usedLettersArray.contains($0) }) ?? "W"
        
        CorrectCounter(numCorrect: usedLetters.count,
                       action: { showUsedLetters.toggle() },
                       letterToShow: letterToShow)
            .onChange(of: usedLetters.count) { newValue in
                if newValue >= 26 { // 26 letters in the alphabet
                    withAnimation(.easeInOut) { showRewards = true }
                }
            }
            .overlay(
                RewardOptions(
                    isShowing: showRewards,
                    addLifeAction: viewModel.frenzyMode ? nil :
                        {
                            withAnimation(.easeInOut) {
                                viewModel.getLifeReward()
                                showRewards.toggle()
                            }
                        },
                    addTimeAction: {
                        withAnimation(.easeInOut) {
                            viewModel.getTimeReward()
                            showRewards.toggle()
                        }
                    })
            )
    }
}

struct RewardOptions: View {
    var isShowing: Bool
    var addLifeAction: (() -> Void)?
    var addTimeAction: () -> Void
    
    var body: some View {
        if isShowing {
            VStack(spacing: 20) {
                if let addLifeAction =  addLifeAction {
                    Button(action: addLifeAction) {
                        Image(systemName: "heart.fill")
                            .resizable().scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                            .shadow(color: .green.opacity(0.5), radius: 3)
                            .pulseEffect()
                    }
                    .buttonStyle(ScaleEffect())
                }
                
                Button(action: addTimeAction) {
                    Image(systemName: "stopwatch")
                        .resizable().scaledToFit()
                        .frame(width: 30, height: 30)
                        .shadow(color: .green.opacity(0.7), radius: 3)
                        .pulseEffect()
                }
                .buttonStyle(ScaleEffect())
            }
            .background(Color.black.opacity(0.3).blur(radius: 10))
            .offset(y: 75)
            .transition(.offset(y: -75).combined(with: .opacity))
        }
    }
}

struct UsedLettersCounter_Previews: PreviewProvider {
    struct UsedLettersCounter_Harness: View {
        @State var numCorrect = 0
        @State var showReward = false
        @State private var usedLetters = Set(["a", "b", "d"])
        var body: some View {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                VStack {
                    
                    UsedLettersCounter(usedLetters: usedLetters, showUsedLetters: .constant(false))
                        .environmentObject(WordBombGameViewModel.preview())
                        
                    Game.MainButton(label: "Plus C") {
                        usedLetters.insert("c")
                    }
                }
            }
        }
    }
    static var previews: some View {
        UsedLettersCounter_Harness()
    }
}
