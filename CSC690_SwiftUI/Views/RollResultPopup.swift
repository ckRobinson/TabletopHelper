//
//  RollResultPopup.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 10/25/21.
//

import SwiftUI

class RollResultPopUpModel: ObservableObject {

    @Published var progress: CGFloat = 1.0
    
    private var countdownTimer: CountdownTimer?

    private var timer: Timer?
    private var runCount: CGFloat?
    private var maxCount: CGFloat?
    
    private let hideCallback: () -> Void
    
    init(timerSeconds: CGFloat, hideCallback: @escaping () -> Void) {

        self.hideCallback = hideCallback

        self.timer = Timer.scheduledTimer(timeInterval: 0.1,
                                          target: self,
                                          selector: #selector(fireTimer),
                                          userInfo: nil,
                                          repeats: true)
        
        self.maxCount = timerSeconds * 10.0
        self.runCount = self.maxCount
        self.countdownTimer = CountdownTimer(model: self)
    }
        
    func getTimer() -> CountdownTimer {
        guard let c = self.countdownTimer else {
            self.countdownTimer = CountdownTimer(model: self)
            return self.countdownTimer!
        }
        return c
    }
    
    @objc func fireTimer(timer: Timer) {
        
        if var runCount = self.runCount,
           let maxCount = self.maxCount {
            
            runCount -= 1
            self.runCount = runCount
            self.progress = CGFloat(runCount / maxCount)
            if self.progress < 0 {
                self.progress = 0
            }
            
            print(progress)
            if runCount <= -0.03 {
                timer.invalidate()
                self.hideCallback()
            }
        }
    }
}

struct RollResultPopupView: View {
    
    var rollTitle: String = ""
    var result: String = ""
    var popupClickedCallback: () -> Void
    
    var popupModel: RollResultPopUpModel
    
    init(title: String, result: String, popupClickedCallback: @escaping () -> Void) {
        self.rollTitle = title
        self.result = result
        
        self.popupClickedCallback = popupClickedCallback
        
        popupModel = RollResultPopUpModel(timerSeconds: 3, hideCallback: popupClickedCallback)
    }

    var body: some View {
        Button(action: {
            self.popupClickedCallback()
        }){
            HStack {
                VStack {
                    HStack {
                        Text("Rolling: \(self.rollTitle)")
                            .padding()
                        Text("Result: \(self.result)")
                            .padding()
                    }
                    popupModel.getTimer().frame(alignment: .bottom).padding(.horizontal)
                }
                .frame(width: UIScreen.main.bounds.width * 0.66, alignment: .leading)
                .background(Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 2)
                        .accentColor(.black)
                )
                .padding(.horizontal)
            }
        }
    }
}

struct RollResultPopup_Previews: PreviewProvider {
    static var previews: some View {
        RollResultPopupView(title: "", result: "", popupClickedCallback: {})
    }
}

struct CountdownTimer: View {
    
    @State var progress: CGFloat = 1.0
    
    @ObservedObject var popupModel: RollResultPopUpModel
    
    init(model: RollResultPopUpModel) {
        self.popupModel = model
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color.gray)
                    .opacity(0.5)
                    .frame(width: geometry.size.width, height: 3.0)
                Rectangle()
                    .foregroundColor(Color.blue)
                    .frame(width: geometry.size.width * self.popupModel.progress, height: 3.0)
            }
            .cornerRadius(4.0)
        }.frame(height:10.0, alignment: .bottom)
    }
    
    func getTimer() -> CountdownTimer {
        return self;
    }
}
