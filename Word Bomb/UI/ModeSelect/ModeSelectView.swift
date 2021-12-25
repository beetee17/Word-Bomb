//
//  ModeSelectView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 2/7/21.
//

import SwiftUI


struct ModeSelectView: View {
    
    @Binding var gameType: GameType
    @Binding var viewToShow: ViewToShow
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \GameMode.name_, ascending: true)],
        animation: .default)
    
    private var modes: FetchedResults<GameMode>
    @State private var contentOverflow = false
    
    var body: some View {
        
        VStack(spacing:25) {
            
            SelectModeText()
            
            VStack(spacing: 50) {
                ForEach(modes, id: \.self) { mode in
                    if mode.gameType == gameType {
                        ModeSelectButton(mode: mode)
                    }
                }
                .transition(.move(edge: .trailing))
                .animation(Game.mainAnimation)
                
            }
            .background(
                // hacky way to ensure geometry is always updated
                GeometryReader { contentGeometry in
                Color.clear
                .onAppear() {
                    contentOverflow = contentGeometry.size.height > Device.height/2
                }
                .onChange(of: Date()) { _ in
                    contentOverflow = contentGeometry.size.height > Device.height/2
                }
            })
            .useScrollView(when: contentOverflow)
            .frame(maxHeight: Device.height/2, alignment: .center)
            .frame(width: Device.width)
            
            Game.backButton {
                withAnimation { viewToShow = .gameTypeSelect }
            }
            .offset(y: 25)
        }
        .frame(width: Device.width, height: Device.height)
        .transition(.move(edge: .trailing))
        .animation(Game.mainAnimation)
    }
}


struct SelectModeText: View {
    
    var body: some View {
        Text("Select Mode")
            .fontWeight(.bold)
            .font(.largeTitle)
    }
}


struct ModeSelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        ModeSelectView(gameType: .constant(.Classic), viewToShow: .constant(.modeSelect))
            .environment(\.managedObjectContext, moc_preview)
            .environmentObject(WordBombGameViewModel.preview)
    }
}
