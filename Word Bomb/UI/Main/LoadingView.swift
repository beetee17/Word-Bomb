//
//  LoadingView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 19/12/21.
//

import SwiftUI

struct LoadingView: View {
    
    @EnvironmentObject var viewModel: CoreDataViewModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea(.all)
            VStack(spacing:50) {
                LogoView()
                ProgressBar(value: $viewModel.progress)
                    .frame(height: 40)
                    .padding(.horizontal)
                Text(viewModel.status)
            }
            .onAppear() {
                viewModel.initDatabases()
            }
        }
    }
}

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.blue)
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
            .environmentObject(CoreDataViewModel())
    }
}
