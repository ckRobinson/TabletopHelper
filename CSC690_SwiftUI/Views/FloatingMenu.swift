//
//  FloatingMenu.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 10/25/21.
//
//  Pieces of original code taken from https://blckbirds.com/post/floating-action-button-in-swiftui/
//  Tutorial code has been modified and repurposed for this use case however.
//
//  This file is in charge of everything required to display the floating dice roller menu.
//  It also currently contains the model class that helps facilitate the updating of the
//  interface based on user input.

import SwiftUI

enum DieType: CaseIterable {
    case D20
    case D12
    case D10
    case D100
    case D8
    case D6
    case D4
}

/// This class holds the model data for the floating menu. It is responsible for generating the proper value which is
/// then passed into the constructor of a new RollResultPopupView. This view is then displayed by the floating menu
/// as long as our published popUpDisplayed bool is true.
///
/// TODO: Update this class to take control of the timers for when the view is visible or not rather than separating that
/// code to other locations.
class FloatingMenuModel: ObservableObject {

    @Published var popUpDisplayed: Bool = false

    @Published var buttonsDisplayed: [Bool] = []
    @Published var buttonImages: [Image] = []
    @Published var buttonText: [String] = []
    @Published var buttonType: [DieType] = []
    
    var popUpTitle: String = ""
    var popUpResult: String = ""
    
    var hidePopupTimer: DispatchWorkItem?
    var waitToShowTimer: DispatchWorkItem?
    
    private var rollResultPopupView: RollResultPopupView?
    private var rollResultPopUpModel: RollResultPopUpModel?
    
    init() {
        for dieType in DieType.allCases {
            buttonsDisplayed.append(false)
            self.buttonType.append(dieType)
        }
    }
    
    func updatePopUp(die: DieType) {
        
        switch die {
            case DieType.D20:
                self.popUpTitle = "1d20"
                self.popUpResult = String(Int.random(in: 1...20))
            case DieType.D12:
                self.popUpTitle = "1d12"
                self.popUpResult = String(Int.random(in: 1...12))
            case DieType.D10:
                self.popUpTitle = "1d10"
                self.popUpResult = String(Int.random(in: 1...10))
            case DieType.D100:
                self.popUpTitle = "1d100"
                self.popUpResult = String(Int.random(in: 1...100))
            case DieType.D8:
                self.popUpTitle = "1d8"
                self.popUpResult = String(Int.random(in: 1...8))
            case DieType.D6:
                self.popUpTitle = "1d6"
                self.popUpResult = String(Int.random(in: 1...6))
            case DieType.D4:
                self.popUpTitle = "1d4"
                self.popUpResult = String(Int.random(in: 1...4))
        }
        
        let model = self.getPopUpModel()
        model.startTimer()
        self.rollResultPopupView = RollResultPopupView(title: self.popUpTitle,
                                                       result: self.popUpResult,
                                                       model: model,
                                                       popupClickedCallback: self.hidePopUp)
    }
    
    func displayPopUp(die: DieType) {

        // Check how we need to display the pop up here.
        if self.popUpDisplayed  == false {
            
            // Show the view
            self.updatePopUp(die: die)
            self.popUpDisplayed = true
        }
        else {
            
            // Else the display is currently visible. So we initially hide the view
            self.popUpDisplayed = false
            
            // Make sure we cancel any active show timers just incase.
            if let waitTimer = self.waitToShowTimer {
                waitTimer.cancel()
            }
            
            // Create and dispatch a new timer to show the new roll result after the current view is off screen.
            self.waitToShowTimer = DispatchWorkItem {
                
                self.updatePopUp(die: die)
                self.popUpDisplayed  = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: self.waitToShowTimer!)
        }
    }
    
    func hidePopUp() -> Void {
        self.popUpDisplayed = false
    }
    
    func getPopUpView() -> RollResultPopupView {
        
        guard let view = self.rollResultPopupView else {
            let view = RollResultPopupView(title: self.popUpTitle,
                                           result: self.popUpResult,
                                           model: self.getPopUpModel(),
                                           popupClickedCallback: self.hidePopUp)
            self.rollResultPopupView = view
            return view
        }
        
        return view
    }
    
    func getPopUpModel() -> RollResultPopUpModel {
        guard let model = self.rollResultPopUpModel else {
            let model = RollResultPopUpModel(timerSeconds: 3, hideCallback: self.hidePopUp)
            self.rollResultPopUpModel = model
            return model
        }
        return model
    }
    
    func getDieButtonView(dieType: DieType) -> some View {
        switch dieType {
        case .D20:
            return MenuItem(icon: Image("Dice-1"), text: "D20")
        case .D12:
            return MenuItem(icon: Image("Dice-2"), text: "D12")
        case .D10:
            return MenuItem(icon: Image("Dice-3"), text: "D10")
        case .D100:
            return MenuItem(icon: Image("Dice-4"), text: "D100")
        case .D8:
            return MenuItem(icon: Image("Dice-5"), text: "D8")
        case .D6:
            return MenuItem(icon: Image("Dice-6"), text: "D6")
        case .D4:
            return MenuItem(icon: Image("Dice-7"), text: "D4")
        }
    }
}

/// The actual floating menu view, contains a set of buttons
struct FloatingMenu: View {
    
    @State var buttonsAreVisible = false
    
    @ObservedObject var model: FloatingMenuModel = FloatingMenuModel()

    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 60, height: self.buttonsAreVisible ? 480 : 0)
                    .opacity(self.buttonsAreVisible ? 0.6 : 0)
                    .animation(Animation.easeOut(duration: 0.25), value: self.buttonsAreVisible)
                    .cornerRadius(100)
                
                VStack {
                    Group {
                        // Create a floating button for each item in the model.
                        ForEach(0..<self.model.buttonsDisplayed.count) { index in
                            
                            Button(action: {
                                self.model.displayPopUp(die: self.model.buttonType[index])
                            }) {
                                self.model.getDieButtonView(dieType: self.model.buttonType[index])
                            }
                            .opacity(self.buttonsAreVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.25).delay(0.025),
                                       value: self.buttonsAreVisible)
                            .disabled(!self.buttonsAreVisible)
                        }
                    }
                    .frame(width: self.buttonsAreVisible ? 60 : 0, height: self.buttonsAreVisible ? .infinity : 0)
                    .animation(Animation.easeOut(duration: 0.5), value: self.buttonsAreVisible)

                    Button(action: {
                        withAnimation {
                            // Flip the main button to display a X image
                            self.buttonsAreVisible.toggle()
                        }
                        self.showMenu()
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(Color(red: 0/255,
                                                       green: 125/255,
                                                       blue: 125/255))
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.gray.opacity(0.75), radius: 3, x: -3, y: 3)
                            if(self.buttonsAreVisible) {
                                Image(systemName: "x.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                    .scaledToFit()
                                    .foregroundColor(Color(red: 0/255,
                                                           green: 0/255,
                                                           blue: 0/255))
                            }
                            else {
                                Image("Dice-1")
                                    .resizable()
                                    .frame(width: 83/2, height: 96/2)
                                    .foregroundColor(Color(red: 156/255,
                                                           green: 163/255,
                                                           blue: 173/255))
                            }
                        }
                    }
                }
            }.padding(.trailing)
        }
        .popup(isPresented: self.model.popUpDisplayed,
               alignment: .bottomLeading,
               direction: .bottom,
               content: self.model.getPopUpView)
    }
    
    func showMenu() {
        
        // Start timers to animate each button in sequence.
        var timer: Int = 0
        for index in 0..<self.model.buttonsDisplayed.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timer), execute: {
                withAnimation {
                    self.model.buttonsDisplayed[index].toggle()
                }
            })
            timer += 50
        }
    }
}

struct MenuItem: View {
    
    var icon: Image
    var text: String
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .foregroundColor(Color(red: 156/255,
                                           green: 163/255,
                                           blue: 173/255))
                    .frame(width: 50, height: 50)
                VStack {
                    icon.resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(text)")
                        .font(.system(size: 14))
                        .scaledToFit()
                        .frame(width: 35, height: 20)
                        .foregroundColor(.black)
                }
            }
            .shadow(color: Color.gray.opacity(0.75), radius: 3, x: -3, y: 3)
            .transition(.move(edge: .top))
        }
    }
}

struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMenu()
    }
}

