//
//  MainView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 3/7/21.
//

import SwiftUI
import GameKit
import GameKitUI

/// Source of truth for `MainView`. Handles programmatic navigation throughout `MainView`and controls the flow of the launch animation.
class MainViewVM: ObservableObject {
    
    static var shared = MainViewVM()
    
    /// `true` when the logo has finished animating. Used for delay purposes; it is toggled after a small amount of time after `animatingLogo` is `true`
    @Published var logoAnimationCompleted = false
    /// `true` if the logo is currently animating.
    @Published var animatingLogo = false
    /// Represents the boolean stored in `UserDefaults` under `"First Launch`
    @Published var isFirstLaunch = UserDefaults.standard.bool(forKey: "First Launch") {
        didSet {
            UserDefaults.standard.setValue(false, forKey: "First Launch")
            print("set first launch to: \(UserDefaults.standard.bool(forKey: "First Launch"))")
        }
    }
    /// `true` if animation has not started yet
    var beforeAnimating: Bool {
        !(animatingLogo || logoAnimationCompleted)
    }
    /// `true` if tutorial overlay should be displayed. The tutorial should be displayed if it is the user's first launch of the game, and after the animation has completed
    var showTutorial: Bool {
        isFirstLaunch && logoAnimationCompleted
    }
    
    /// `true` if user has selected `"CREATE MODE"`
    @Published var creatingMode = false
    /// `true` if user has selected `"SETTINGS"`
    @Published var changingSettings = false
    /// Toggled when user selects `"START GAME"`
    @Published var showPlayOptions = false
    /// Toggled when user selects `"MULTIPLAYER"`
    @Published var showMatchMakerModal = false
    
    /// `true` if user has selected `"DATABASE"`
    @Published var searchingDatabase = false
    
    /// Begins the animation. Should be called when `MainView` appears
    func beginAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 1)) {
            animatingLogo = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            
            withAnimation(.easeInOut) { self.logoAnimationCompleted = true }
        }
    }
    
    /// Called when the user dismisses the tutorial overlay
    func dismissTutorial() {
        isFirstLaunch = false
    }
    /// Called when the user selects `"START GAME"`
    func startGame() {
        showPlayOptions.toggle()
    }
    /// Called when the user selects `"ARCADE MODE`
    func arcadeMode() {
        Game.viewModel.arcadeMode = true
        showPlayOptions = false
        Game.viewModel.startGame()
    }
    /// Called when the user selects `"FRENZY MODE`
    func frenzyMode() {
        Game.viewModel.frenzyMode = true
        showPlayOptions = false
        Game.viewModel.startGame()
    }
    /// Called when the user selects `"MULTIPLAYER"`
    func onlinePlay() {
        Game.viewModel.gkSelect = true
        showPlayOptions = false
        showMatchMakerModal = true
    }
    /// Called when the user selects `"SETTINGS"`
    func changeSettings() {
        changingSettings = true
    }
    /// Called when the user selects `"CREATE MODE"`
    func createMode() {
        creatingMode = true
    }
    /// Called when the user selects `"DATABASE"`
    func searchDBs() {
        searchingDatabase = true
    }
}

struct MainView: View {
    
    @ObservedObject var viewModel = MainViewVM.shared
    @Namespace var mainView
    
    var body: some View {
        
        ZStack {
            
            Color.clear
            
            VStack(spacing:1) {
                if viewModel.animatingLogo {
                    RotatingBomb(isRotating: $viewModel.logoAnimationCompleted)
                        .matchedGeometryEffect(id: "logo", in: mainView, isSource: false)
                }
                
                MainMenuView(viewModel: viewModel)
                    .opacity(viewModel.logoAnimationCompleted ? 1 : 0)
            }
            .padding(.bottom, 20)
            .blur(radius: viewModel.showTutorial ? 2 : 0)
            
            if viewModel.beforeAnimating {
                RotatingBomb(isRotating: $viewModel.logoAnimationCompleted)
                    .matchedGeometryEffect(id: "logo", in: mainView, isSource: true)
                    .frame(width: Device.width, height: Device.height, alignment: .center)
                    .onAppear() { viewModel.beginAnimation() }
            }
            
            if viewModel.showTutorial {
                FirstLaunchInstructionsView()
            }
            
        }
        .transition(.asymmetric(insertion: AnyTransition.move(edge: .leading), removal: AnyTransition.move(edge: .trailing)))
        .animation(Game.mainAnimation)
        .zIndex(1) // transition does not work with zIndex set to 0
        .onDisappear {
            // for logo animation to be performed
            viewModel.animatingLogo = false
            viewModel.logoAnimationCompleted = false
        }
    }
}

struct MainMenuView: View {
    
    @ObservedObject var viewModel: MainViewVM
    @EnvironmentObject var gameVM: WordBombGameViewModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing:15) {
            
            Game.MainButton(label: "START GAME", systemImageName: "gamecontroller") { viewModel.startGame() }
            
            if viewModel.showPlayOptions {
                
                VStack(spacing:15) {
                    
                    Game.MainButton(label: "ARCADE MODE",
                                    image: AnyView(Image("brain")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width:30))) {
                        viewModel.arcadeMode()
                        
                    }
                    Game.MainButton(label: "FRENZY MODE",
                                    systemImageName: "bolt.fill") {
                        viewModel.frenzyMode()
                        
                    }
                    
                    Game.MainButton(label: "MULTIPLAYER",
                                    image: AnyView(Image("GK Icon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 23))) {
                        viewModel.onlinePlay()
                    }
                    
                }
                .transition(.opacity)
            }
            else {
                
                VStack(spacing:15) {
                    Game.MainButton(label: "CREATE MODE", systemImageName: "plus.circle") { viewModel.createMode() }
                    .sheet(isPresented: $viewModel.creatingMode) {
                        CustomModeForm()
                            .environmentObject(errorHandler)
                            .environment(\.managedObjectContext, viewContext)
                    }
                    
                    Game.MainButton(label: "DATABASE", systemImageName: "magnifyingglass.circle") { viewModel.searchDBs() }
                    .sheet(isPresented: $viewModel.searchingDatabase) {
                        DatabaseListView()
                            .environment(\.managedObjectContext, viewContext)
                            .environmentObject(errorHandler)
                    }
                    
                    Game.MainButton(label: "SETTINGS", systemImageName: "gearshape") { viewModel.changeSettings() }
                    .sheet(isPresented: $viewModel.changingSettings) { SettingsMenu().environmentObject(gameVM) }
                }
             
                .transition(AnyTransition
                                .offset(x:0, y:200)
                                .combined(with: .move(edge: viewModel.showPlayOptions ? .top : .bottom)
                                .combined(with: .opacity)))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75, blendDuration: 0.2))
        .sheet(isPresented: $viewModel.showMatchMakerModal) {
            // From Apple Docs: The maximum number of players for the GKMatchType.peerToPeer, GKMatchType.hosted, and GKMatchType.turnBased types is 16.
            GKMatchmakerView(
                minPlayers: 2,
                maxPlayers: 10,
                inviteMessage: "Let us play together!"
            ) {
                viewModel.showMatchMakerModal = false
                
            } failed: { (error) in
                viewModel.showMatchMakerModal = false
                Game.errorHandler.showBanner(title: "Match Making Failed", message: error.localizedDescription)
            } started: { (match) in
                viewModel.showMatchMakerModal = false
                viewModel.startGame()
                
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
