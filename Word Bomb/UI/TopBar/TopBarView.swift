//
//  TopBarView.swift
//  Word Bomb
//
//  Created by Brandon Thio on 6/7/21.
//

import SwiftUI
import GameKit

struct TopBarView: View {
    
    @EnvironmentObject var viewModel: WordBombGameViewModel
    
    var props: Props {
        viewModel.topBarViewProps
    }
    
    @Binding var gamePaused: Bool
    @Binding var showMatchProgress: Bool
    @Binding var showUsedLetters: Bool
    
    var gkMatch: GKMatch?
    
    var body: some View {
        print("Redrawing TopBarView")
        return HStack {
            Spacer()
                .overlay(
                    TopLeft(gamePaused: $gamePaused,
                            gkMatch: gkMatch)
                )
                .frame(width: Device.width*0.2)
                .offset(y: Device.height*0.015)
            
            TimerView(props: props.timerViewProps,
                      isAnimatingTimeDelta: $viewModel.model.controller.animateTimeDelta,
                      isAnimatingExplosion: $viewModel.model.controller.animateExplosion)
                .offset(x: gkMatch == nil ? 0 : -20)
                .frame(width: Device.width*0.5)
                .offset(x: Device.width*0.05)
             
            Spacer()
                .overlay(
                    TopRight(props: props.topRightProps,
                             showMatchProgress: $showMatchProgress,
                             showUsedLetters: $showUsedLetters)
                )
                .offset(y: Device.height*0.015)
        }
        // The top bar is smaller when there are less than 3 players due to the bomb explosion animation.
        .frame(height: Game.miniBombSize*1.17)
        .offset(x: 0, y: -Device.height*0.04)
    }
}


struct TopLeft: View {
    @Binding var gamePaused: Bool
    var gkMatch: GKMatch?
    
    var body: some View {
        print("Redrawing TopLeftView")
        return ZStack {
            switch gkMatch == nil {
            case true:
                PauseButton(gamePaused: $gamePaused)
            case false:
                GKQuitButton()
            }
        }
    }
}

struct TopRight: View {
    
    var props: Props
    
    @Binding var showMatchProgress: Bool
    @Binding var showUsedLetters: Bool
    
    var body: some View {
        let singlePlayer = props.frenzyMode || props.arcadeMode
        print("Redrawing TopRightView")
        return ZStack {
            if .GameOver == props.gameState {
                RestartButton()
            } else if !singlePlayer && !showMatchProgress {
                CorrectCounter(
                    numCorrect: props.numCorrect,
                    action: { showMatchProgress.toggle() })
            } else if singlePlayer && !showUsedLetters {
                UsedLettersCounter(props: props.usedLettersCounterProps,
                                   showUsedLetters: $showUsedLetters)
            }
        }
    }
}

extension TopBarView {
    struct Props: Equatable {
        var frenzyMode: Bool
        var arcadeMode: Bool
        
        var gameState: GameState?
        var numCorrect: Int
        var usedLetters: Set<String>
        
        var timeLeft: Float
        var timeLimit: Float
        var timeDelta: Int
        
        var numPlayers: Int
        
        var topRightProps: TopRight.Props {
            .init(frenzyMode: frenzyMode,
                  arcadeMode: arcadeMode,
                  numCorrect: numCorrect,
                  usedLetters: usedLetters)
        }
    }
}

extension TopRight {
    struct Props: Equatable {
        var frenzyMode: Bool
        var arcadeMode: Bool
        
        var gameState: GameState?
        var numCorrect: Int
        var usedLetters: Set<String>
        
        var usedLettersCounterProps: UsedLettersCounter.Props {
            .init(frenzyMode: frenzyMode, usedLetters: usedLetters)
        }
    }
}

extension WordBombGameViewModel {
    var topBarViewProps: TopBarView.Props {
        .init(frenzyMode: frenzyMode,
              arcadeMode: arcadeMode,
              numCorrect: model.numCorrect,
              usedLetters: model.players.current.usedLetters,
              timeLeft: model.controller.timeLeft,
              timeLimit: model.controller.timeLimit,
              timeDelta: model.controller.timeDelta,
              numPlayers: model.players.playing.count)
    }
}
    
struct TopBarView_Previews: PreviewProvider {
    
    struct TopBarView_Harness: View {
        @ObservedObject var viewModel = WordBombGameViewModel()
        
        var body: some View {
            VStack {
                TopBarView(gamePaused: .constant(false),
                           showMatchProgress: .constant(false),
                           showUsedLetters: .constant(false))
                    .environmentObject(viewModel)
                Game.MainButton(label: "1", systemImageName: "plus.circle") {
                    viewModel.model.numCorrect += 1
                }
                Game.MainButton(label: "10", systemImageName: "multiply.circle") {
                    viewModel.model.numCorrect *= 10
                }
            }
            .background(Color("Background"))
        }
    }
    static var previews: some View {
        TopBarView_Harness()
    }
}
