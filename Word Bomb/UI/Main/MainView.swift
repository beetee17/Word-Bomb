//
//  MainView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 3/7/21.
//

import SwiftUI
import GameKit
import GameKitUI

class MainViewVM: ObservableObject {
    
    @Published var logoAnimationCompleted = false // for delay purpose
    @Published var animatingLogo = false
    @Published var isFirstLaunch = UserDefaults.standard.bool(forKey: "First Launch") {
        didSet {
            UserDefaults.standard.setValue(false, forKey: "First Launch")
            print("set first launch to: \(UserDefaults.standard.bool(forKey: "First Launch"))")
        }
    }
    var beforeAnimating: Bool {
        !(animatingLogo || logoAnimationCompleted)
    }
    var showTutorial: Bool {
        isFirstLaunch && logoAnimationCompleted
    }
    
    @Published var creatingMode = false
    @Published var changingSettings = false
    @Published var showMultiplayerOptions = false
    @Published var searchingDatabase = false
    
    var gameVM = Game.viewModel
    
    func beginAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 1)) {
            animatingLogo = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            
            withAnimation(.easeInOut) { self.logoAnimationCompleted = true }
        }
    }
    
    func dismissTutorial() {
        isFirstLaunch = false
    }
    
    func startGame() {
        showMultiplayerOptions.toggle()
    }
    func passPlay() {
        gameVM.viewToShow = .gameTypeSelect
        showMultiplayerOptions = false
    }
    func onlinePlay() {
        // bug where tapping the button does not immediately dismiss the main view?
        if gameVM.viewToShow == .main {
            print("selected game center")
            gameVM.viewToShow = .gameTypeSelect
            gameVM.gkSelect = true
            showMultiplayerOptions = false
        }
    }
    func changeSettings() {
        changingSettings = true
    }
    func createMode() {
        creatingMode = true
    }
    func searchDBs() {
        searchingDatabase = true
    }
}

struct MainView: View {
    
    @StateObject var viewModel = MainViewVM()
    @Namespace var mainView
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            VStack(spacing:1) {
                if viewModel.animatingLogo {
                    LogoView()
                        .matchedGeometryEffect(id: "logo", in: mainView, isSource: false)
                }
                
                MainMenuView(viewModel: viewModel)
                    .opacity(viewModel.logoAnimationCompleted ? 1 : 0)
            }
            .padding(.bottom, 20)
            .blur(radius: viewModel.showTutorial ? 2 : 0)
            
            if viewModel.beforeAnimating {
                LogoView()
                    .matchedGeometryEffect(id: "logo", in: mainView, isSource: true)
                    .frame(width: Device.width, height: Device.height, alignment: .center)
                    .onAppear() { viewModel.beginAnimation() }
            }
            
            if viewModel.showTutorial {
                FirstLaunchInstructionsView().onTapGesture { viewModel.dismissTutorial() }
            }
            
        }
        .transition(.asymmetric(insertion: AnyTransition.move(edge: .leading), removal: AnyTransition.move(edge: .trailing)))
        .animation(Game.mainAnimation)
        .zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/) // transition does not work with zIndex set to 0
        
    }
}

struct MainMenuView: View {
    
    @ObservedObject var viewModel: MainViewVM
    @EnvironmentObject var gameVM: WordBombGameViewModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing: 20) {
            Game.mainButton(label: "START GAME", systemImageName: "gamecontroller") { viewModel.startGame() }
            
            if viewModel.showMultiplayerOptions {
                
                VStack(spacing:10) {
                    Game.mainButton(label: "PASS & PLAY", systemImageName: "person.3") { viewModel.passPlay() }
                    
                    Game.mainButton(label: "GAME CENTER",
                                    image: AnyView(Image("GK Icon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 20))) {
                        viewModel.onlinePlay()
                    }
                }
            }
            Game.mainButton(label: "CREATE MODE", systemImageName: "plus.circle") { viewModel.createMode() }
            .sheet(isPresented: $viewModel.creatingMode) {
                CustomModeForm()
                    .environmentObject(errorHandler)
                    .environment(\.managedObjectContext, viewContext)
                
            }
            
            Game.mainButton(label: "DATABASE", systemImageName: "magnifyingglass.circle") { viewModel.searchDBs() }
            .sheet(isPresented: $viewModel.searchingDatabase) {
                DatabaseListView()
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(errorHandler)
            }
            
            Game.mainButton(label: "SETTINGS", systemImageName: "gearshape") { viewModel.changeSettings() }
            .sheet(isPresented: $viewModel.changingSettings) { SettingsMenu().environmentObject(gameVM)
            }
        }
    }
}
struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            MainView()
        }
    }
}
