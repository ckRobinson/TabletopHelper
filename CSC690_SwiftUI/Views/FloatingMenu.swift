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
    
    
    var hidePopupTimer: DispatchWorkItem?
    var waitToShowTimer: DispatchWorkItem?
    
    private var rollResultPopup: RollResultPopupView = RollResultPopupView(title: "",
                                                                   result: "",
                                                                   popupClickedCallback: {})
    
    init() {
        for dieType in DieType.allCases {
            buttonsDisplayed.append(false)
            self.buttonType.append(dieType)
        }
    }
    
    func updatePopUp(die: DieType) {
        
        let result: Int
        let title: String
        switch die {
            case DieType.D20:
                title = "1d20"
                result = Int.random(in: 1...20)
            case DieType.D12:
                title = "1d12"
                result = Int.random(in: 1...12)
            case DieType.D10:
                title = "1d10"
                result = Int.random(in: 1...10)
            case DieType.D100:
                title = "1d100"
                result = Int.random(in: 1...100)
            case DieType.D8:
                title = "1d8"
                result = Int.random(in: 1...8)
            case DieType.D6:
                title = "1d6"
                result = Int.random(in: 1...6)
            case DieType.D4:
                title = "1d4"
                result = Int.random(in: 1...4)
        }
        
        self.rollResultPopup = RollResultPopupView(title: title,
                                               result: "\(result)",
                                               popupClickedCallback: self.hidePopUp)
    }
    
    func displayPopUp(die: DieType) {

        // Cancel the timer that was going to close the view, then recreate a timer and dispatch it.
//        if let popupTimer = self.hidePopupTimer {
//            popupTimer.cancel()
//        }
//        self.hidePopupTimer = DispatchWorkItem {
//            self.popUpDisplayed  = false
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: self.hidePopupTimer!)

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
    
    func getPopUp() -> () -> RollResultPopupView {
        return { () -> RollResultPopupView in return self.rollResultPopup }
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
    
    @State var mainButton = false
        
    @ObservedObject var model: FloatingMenuModel = FloatingMenuModel()

    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                
                // Create a floating button for each item in the model.
                ForEach(0..<self.model.buttonsDisplayed.count) { index in
                    
                    if self.model.buttonsDisplayed[index] {
                        Button(action: {
                            self.model.displayPopUp(die: self.model.buttonType[index])
                        }) {
                            self.model.getDieButtonView(dieType: self.model.buttonType[index])
                        }
                    }
                }
                Button(action: {
                    self.showMenu()
                }) {
                    ZStack {
                        Circle()
                            .foregroundColor(Color(red: 0/255,
                                                   green: 125/255,
                                                   blue: 125/255))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.gray.opacity(0.75), radius: 3, x: -3, y: 3)
                        if(self.mainButton) {
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
            }.padding(.trailing)
        }
        .popup(isPresented: self.model.popUpDisplayed,
               alignment: .bottomLeading,
               direction: .bottom,
               content: self.model.getPopUp())
    }
    
    func showMenu() {
        
        // Flip the main button to display a X image
        self.mainButton.toggle()

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

