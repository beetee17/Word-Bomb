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
/// Created by smuellner on 22.02.21.
///

import SwiftUI
import GameKitUI

struct AuthenticationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var gameViewModel: WordBombGameViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing:50) {
                VStack {
                    Text(self.viewModel.currentState)
                        .font(.title2).bold()
                    
                    if self.viewModel.isAuthenticated,
                       let player = self.viewModel.player {
                        GKPlayerView(viewModel: GKPlayerViewModel(player))
                        Game.MainButton(label: "REAUTHENTICATE", systemImageName: "lock.fill") {
                            self.viewModel.showAuthenticationModal()
                        }
                        .padding(.top, 25)
                    } else {
                        Game.MainButton(label: "LOGIN", systemImageName: "lock.fill") {
                            self.viewModel.showAuthenticationModal()
                        }
                    }
                    
                }
                Game.BackButton {
//                    gameViewModel.viewToShow = .GKMain
                }
            }
            
        }
        .helpButton()
        .onAppear() {
            self.viewModel.load()
        }
        .sheet(isPresented: self.$viewModel.showModal) {
            GKAuthenticationView { (error) in
                self.viewModel.showModal = false
                self.viewModel.showAlert(title: "Authentication Failed", message: error.localizedDescription)
                self.viewModel.currentState = error.localizedDescription
            } authenticated: { (player) in
                self.viewModel.showModal = false
                self.viewModel.player = player
                self.viewModel.currentState = "Authenticated"
            }
            .frame(width: 640, height: 480)
        }
        .alert(isPresented: self.$viewModel.showAlert) {
            Alert(title: Text(self.viewModel.alertTitle),
                  message: Text(self.viewModel.alertMessage),
                  dismissButton: .default(Text("Ok")))
        }
        .frame(width: Device.width, height: Device.height)
        .transition(.move(edge: .trailing))
        .animation(Game.mainAnimation)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
