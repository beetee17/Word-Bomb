///
/// MIT License
///
/// Copyright (c) 2020 Sascha Müllner
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
///
/// Created by Sascha Müllner on 03.04.21.

import SwiftUI
import GameKit

struct GKPlayerView: View {
    @ObservedObject var viewModel: GKPlayerViewModel
    @State var playerImage: UIImage?
    var body: some View {
        VStack(alignment: .center, spacing: 16) {

            if let image = playerImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            else {
                Image("GK Profile")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 128, height: 128)
                
            }
            Text(self.viewModel.player.displayName)
            VStack(alignment: .center, spacing: 4) {
                Text("Alias: \(self.viewModel.player.alias)")
                    .font(.footnote)
                Text(self.viewModel.player.gamePlayerID)
                    .font(.footnote)
                Text(self.viewModel.player.teamPlayerID)
                    .font(.footnote)
            }
        }
        .onAppear() {
            DispatchQueue.global().async {
                GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.normal) { (image, error) in
                    print("\(String(describing: error)) Error loading GKPlayer Image: \(image ?? nil)")
                    playerImage = image
                    
                }
            }
        }
    }
}

class GKPlayerViewModel: ObservableObject {
    
    let player: GKPlayer
    
    @Published var displayName: String
    
    public init(_ player: GKPlayer) {
        self.player = player
        self.displayName = self.player.displayName
    }
}
