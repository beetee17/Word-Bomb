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
    /// Toggled when user selects `"SINGLE PLAYER"`
    @Published var showSinglePlayerOptions = false
    /// Toggled when user selects `"MULTIPLAYER"`
    @Published var showMultiplayerOptions = false
    
    /// Toggled when user selects `"GAME CENTER"`
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
    func singlePlayer() {
        showSinglePlayerOptions.toggle()
        showMultiplayerOptions = false
    }
    
    /// Called when the user selects `"START GAME"`
    func multiplayer() {
        showMultiplayerOptions.toggle()
        showSinglePlayerOptions = false
    }
    
    /// Called when the user selects `"ARCADE MODE`
    func arcadeMode() {
        Game.viewModel.arcadeMode = true
        showSinglePlayerOptions = false
        showMultiplayerOptions = false
        Game.viewModel.startGame()
    }
    /// Called when the user selects `"FRENZY MODE`
    func frenzyMode() {
        Game.viewModel.frenzyMode = true
        showSinglePlayerOptions = false
        showMultiplayerOptions = false
        Game.viewModel.startGame()
    }
    /// Called when the user selects `"MULTIPLAYER"`
    func onlinePlay() {
        Game.viewModel.gkSelect = true
        showSinglePlayerOptions = false
        showMultiplayerOptions = false
        showMatchMakerModal = true
    }
    
    /// Called when the user selects `"PASS & PLAY"`
    func passPlay() {
        showSinglePlayerOptions = false
        showMultiplayerOptions = false
        Game.viewModel.startGame()
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
        .overlay(MuteButton(), alignment: .topLeading)
    }
}

struct MainMenuView: View {
    
    @ObservedObject var viewModel: MainViewVM
    @EnvironmentObject var gameVM: WordBombGameViewModel
    @EnvironmentObject var errorHandler: ErrorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        let showingOptions = viewModel.showMultiplayerOptions || viewModel.showSinglePlayerOptions
        
        VStack(spacing:15) {
            
            Game.MainButton(label: "SINGLE PLAYER",
                            image: AnyView(Image("brain")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 23))) { viewModel.singlePlayer() }
                                            .scaleEffect(showingOptions ? 0.9 : 1)
            
            
            if viewModel.showSinglePlayerOptions {
                
                VStack(spacing:15) {
                    
                    Game.MainButton(label: "ARCADE MODE",
                                    systemImageName: "gamecontroller") {
                        viewModel.arcadeMode()
                        
                    }
                    Game.MainButton(label: "FRENZY MODE",
                                    systemImageName: "bolt.fill") {
                        viewModel.frenzyMode()
                        
                    }
                    
                    
                }
                .pulseEffect()
                .transition(.opacity)
                
            }
            
            Game.MainButton(label: "MULTIPLAYER", systemImageName: "person.3.fill") { viewModel.multiplayer() }
            .offset(y: viewModel.showSinglePlayerOptions ? 300 : 0)
            .opacity(viewModel.showSinglePlayerOptions ? 0 : 1)
            .scaleEffect(showingOptions ? 0.9 : 1)
            
            
            if viewModel.showMultiplayerOptions {
                VStack {
                    Game.MainButton(label: "GAME CENTER",
                                    image: AnyView(Image("GK Icon")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(height: 23))) {
                        viewModel.onlinePlay()
                    }
                    Game.MainButton(label: "PASS & PLAY",
                                    systemImageName: "house.fill") {
                        viewModel.passPlay()
                    }
                }
                .pulseEffect()
                .transition(.opacity)
            }
            if !(viewModel.showMultiplayerOptions || viewModel.showSinglePlayerOptions){
                
                VStack(spacing:15) {
                    
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
                                .offset(y: 300)
                                .combined(with: .move(edge: viewModel.showSinglePlayerOptions ? .top : .bottom)
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
                print("GAME START")
                gameVM.startGame()
                
                
            }
        }
    }
}

struct MuteButton: View {
    @ObservedObject var settings = SettingsMenuVM.shared
    var body: some View {
        let gameIsMuted = !(settings.soundTrack || settings.soundFXs)
        Button(action: {
            if gameIsMuted {
                settings.soundTrack = true
                settings.soundFXs = true
            } else {
                settings.soundTrack = false
                settings.soundFXs = false
            }
        }) {
            Image(systemName: gameIsMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                .resizable().scaledToFit()
                .frame(height: 20)
                .foregroundColor(.white)
                .padding(.leading, 20)
                .padding(.top, Device.height*0.045)
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
