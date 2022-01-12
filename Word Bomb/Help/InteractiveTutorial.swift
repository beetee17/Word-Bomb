//
//  FrenzyHelp.swift
//  Word Bomb
//
//  Created by Brandon Thio on 8/1/22.
//

import SwiftUI

enum HelpElement {
    case None
    case Pause
    case Timer
    case CorrectCount
    case Rewards
    case ChargeUp
    case FreePass
    case Lives
    case Avatar
    case OtherPlayers
    case Score
    case Query
    case Pass
}

protocol HelpViewModel: ObservableObject {

    var animateHelpText: Bool { get set }
    var animateHelpTextPublished: Published<Bool> { get }
    var animateHelpTextPublisher: Published<Bool>.Publisher { get }
    
    var correctCount: Int { get }
    var timeLeft: Float { get }
    
    var focusedElement: HelpElement { get set }
    var focusedElementPublished: Published<HelpElement> { get }
    var focusedElementPublisher: Published<HelpElement>.Publisher { get }
    
    func isVisible(_ element: HelpElement) -> Bool
    func getHelpText(for element: HelpElement) -> String?
    func getHelpTextOffset(for element: HelpElement) -> CGFloat?
}

struct InteractiveTutorial<T: HelpViewModel>: View {

    @ObservedObject var viewModel: T
    
    var body: some View {
        let focusingOn = viewModel.focusedElement
        let dummyPlayer = Player(name: "Player", queueNumber: 0)
        
        ZStack {
            Color("Background").ignoresSafeArea()
            
            if viewModel.isVisible(.Pause) {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 20)
                    .modifier(SpotlightEffect(viewModel: viewModel,
                                              element: .Pause))
                    .position(x: Device.width*0.1,
                              y: Device.height*0.04)
            }
                
            
            Group {
                
                Group {
                    TimerView()
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .Timer))
                        .position(x: Device.width/2,
                              y: Device.height*0.025)
                    CorrectCounter(
                        numCorrect: viewModel.correctCount,
                        action: {
                            viewModel.focusedElement = .CorrectCount
                            withAnimation {
                                viewModel.animateHelpText = true
                            }
                        })
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .CorrectCount))
                        .position(x: Device.width*0.9,
                                  y: Device.height*0.04)
                    
                    
                }
                Group {
                    PlayerAvatar(player: dummyPlayer)
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .Avatar))
                        .position(x: Device.width/2,
                                  y: Device.height*0.3)
                    .scaleEffect(1.05)

                    ScoreCounter(score: 10, imagePicker: StarImagePicker())
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .Score))
                        .position(x: Device.width/2,
                                  y: Device.height*0.2)
                    
                }
                
                if viewModel.isVisible(.OtherPlayers) {
                    
                    Group {
                        MainPlayer(player: dummyPlayer, chargeUpBar: true,
                                   showScore: .constant(true),
                                   showName: .constant(false),
                                   showLives: .constant(true))
                            .opacity(0.6)
                            .scaleEffect(0.85)
                            .modifier(SpotlightEffect(viewModel: viewModel,
                                                      element: .OtherPlayers))
                            .position(x: Device.width*0.2,
                                      y: Device.height*0.25)
                        
                        MainPlayer(player: dummyPlayer, chargeUpBar: true,
                                   showScore: .constant(true),
                                   showName: .constant(false),
                                   showLives: .constant(true))
                            .opacity(0.6)
                            .scaleEffect(0.85)
                            .modifier(SpotlightEffect(viewModel: viewModel,
                                                      element: .OtherPlayers))
                            .position(x: Device.width*0.8,
                                      y: Device.height*0.25)
                        ChargeUpBar(imagePicker: StarImagePicker(),
                                    value: 25,
                                    multiplier: 2,
                                    invert: true)
                            .frame(width: 10, height: 100)
                          
                            .modifier(SpotlightEffect(viewModel: viewModel,
                                                      element: .ChargeUp))
                            .position(x: Device.width*0.34,
                                      y: Device.height*0.3)
                    }
                    .environmentObject(Game.viewModel)
                    
                    
                } else {
                    ChargeUpBar(imagePicker: StarImagePicker(),
                                value: 25,
                                multiplier: 2,
                                invert: false)
                        .frame(height: Device.height*0.035)
                        .padding(.horizontal)
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .ChargeUp))
                        .position(x: Device.width/2,
                                  y: Device.height*0.15)
                    GoldenTickets(numTickets: 3,
                                  claimAction: {
                        viewModel.focusedElement = .FreePass
                        withAnimation {
                            viewModel.animateHelpText = true
                        }
                    } )
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .FreePass))
                        .position(x: Device.width/2,
                                  y: Device.height*0.25)
                    
                    RewardOptions(isShowing: true,
                                  addLifeAction: nil,
                                  addTimeAction: {
                        viewModel.focusedElement = .Rewards
                        withAnimation {
                            viewModel.animateHelpText = true
                        }
                    })
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .Rewards))
                        .position(x: Device.width*0.9,
                                  y: Device.height*0.01)
                }

                if viewModel.isVisible(.Lives) {
                    PlayerLives(player: dummyPlayer)
                        .modifier(SpotlightEffect(viewModel: viewModel,
                                                  element: .Lives))
                        .position(x: Device.width/2,
                                  y: Device.height*0.38)
                }
                
                if viewModel.isVisible(.Pass) {
                    Game.MainButton(label: "PASS", systemImageName: "questionmark.square.fill") {
                        viewModel.focusedElement = .Pass
                        withAnimation { viewModel.animateHelpText = true }
                    }
                    .modifier(SpotlightEffect(viewModel: viewModel,
                                              element: .Pass))
                    .position(x: Device.width/2,
                              y: Device.height*0.4)
                    
                }
                
                VStack {
                    Text("Words Containing" ).boldText()
                    Text("in").boldText()
                }
                .modifier(SpotlightEffect(viewModel: viewModel,
                                          element: .Query))
                .position(x: Device.width/2,
                          y: Device.height*0.45)
                
                if viewModel.animateHelpText  {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .zIndex(9)
                    HelpText(message: viewModel.getHelpText(for: focusingOn) ?? "")
                        .zIndex(9)
                        .position(x: Device.width/2,
                                  y: Device.height * (viewModel.getHelpTextOffset(for: focusingOn) ?? 0))
                        .transition(.scale)
                }
            }
            
        }
        .onTapGesture {
            withAnimation {
                viewModel.focusedElement = .None
                viewModel.animateHelpText = false
            }
        }
    }
}

struct SpotlightEffect<T: HelpViewModel>: ViewModifier {
    
    @ObservedObject var viewModel: T
    var element: HelpElement
    
    func body(content: Content) -> some View {
        content
            .zIndex(viewModel.focusedElement == element ? 10 : 1)
            .if(viewModel.focusedElement == element) { $0.pulseEffect() }
            .onTapGesture {
                viewModel.focusedElement = element
                withAnimation {
                    viewModel.animateHelpText = true
                }
            }
    }
}

struct HelpText: View {
    @State var message: String

    var body: some View {
        VStack(spacing: 50) {
            Text(message)
                .font(.system(.title3, design: .monospaced))
//                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 50)
        .padding(.horizontal, 15)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
}

struct FrenzyHelp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            InteractiveTutorial(viewModel: MultiplayerHelpViewModel())
            InteractiveTutorial(viewModel: FrenzyHelpViewModel())
//            InteractiveTutorial(viewModel: ArcadeHelpViewModel())
        }
    }
}
