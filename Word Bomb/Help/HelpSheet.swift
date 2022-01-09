//
//  HelpSheet.swift
//  Word Bomb
//
//  Created by Brandon Thio on 7/1/22.
//

import SwiftUI

struct HelpButton: View {
    
    var action: () -> Void
    var border: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: action ) {
                    Image(systemName: "questionmark.circle")
                        .font(.title2)
                        .foregroundColor(.white)
                        
                        .frame(width: 70, height: 100, alignment:.center) // tappable area
                        .background(border ? Color.white.opacity(0.2) : Color.clear)
                    
                }
                .clipShape(Circle().scale(0.8))
                .if(border) { $0.pulseEffect() }
            }
            Spacer()
        }
    }
}

struct HelpSheet: ViewModifier {
    
    @State private var showHelpSheet = false
    var action: () -> Void
    var messages = Game.helpMessages
    
    func body(content: Content) -> some View {
        ZStack {
            content
            HelpButton(action: {
                print("Show Help")
                action()
                showHelpSheet = true
            }, border: false)
            .fullScreenCover(isPresented: $showHelpSheet) {
                HelpScreen(isPresented: $showHelpSheet)
            }
        }
        .ignoresSafeArea(.all)
    }
}


struct HelpScreen: View {
    @Binding var isPresented: Bool
    @StateObject var arcade = ArcadeHelpViewModel()
    @StateObject var frenzy = FrenzyHelpViewModel()
    @StateObject var multiplayer = MultiplayerHelpViewModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Game Overview", destination: HelpMessages())
                Section(header: Text("Interactive Tutorials")) {
                    NavigationLink("Arcade Mode", destination: InteractiveTutorial(viewModel: arcade))
                    NavigationLink("Frenzy Mode", destination: InteractiveTutorial(viewModel: frenzy))
                    NavigationLink("Multiplayer", destination: InteractiveTutorial(viewModel: multiplayer))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Help"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "multiply.circle")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .onTapGesture {
                            isPresented.toggle()
                        }
                }
            }
        }
    }
}

struct HelpScreen_Previews: PreviewProvider {
    static var previews: some View {
        HelpScreen(isPresented: .constant(true))
    }
}

