//
//  RandomGeneratorFromTableView.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 11/23/21.
//

import SwiftUI

struct RandomGeneratorFromTableView: View {
    
    @State var data: String = ""
    let generatorTitle: String
    let dismissCallback: (() -> Void)?
    
    var generator: RandomGeneratorFromTableSet? = nil

//    init(generatorTitle: String, generator: RandomGeneratorFromTableSet?, initialData: String, dismissCallback: (() -> Void)? = nil) {
//        self.generatorTitle = generatorTitle
//        self.generator = generator
//        self.dismissCallback = dismissCallback ?? {}
//        self.data = initialData
//    }
    
    var body: some View {
        VStack {

            Capsule()
                .fill(Color.secondary)
                .frame(width: 30, height: 3)
                .padding(10)
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack {
                    Text(self.generatorTitle)
                        .frame(minWidth: 0, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .padding()
                        .font(.headline)
                    
                    VStack {
                        ForEach(data.components(separatedBy: "\n"), id: \.self) { line in
                            if line != "" {
                                Text(line
                                        .trimmingCharacters(in: .whitespaces)
                                        .sentenceCapitalized)
                                    .padding(2.0)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 0, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding(.vertical)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2) // Draw the border before padding horizonatal to fix render issue
                    .padding(.horizontal)

                    HStack {
                        Button(action: {
                            if var g = generator {
                                self.data = g.generate()
                            }
                            else {
                                self.data = "No generator available."
                            }
                        }, label: {
                            Text("Generate Another")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        })
                        .padding()
                        Button(action: {
                            UIPasteboard.general.string = self.data
                        }, label: {
                            Text("Copy to Clipboard")
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        })
                        .padding()
                    }
                }
                
            }
            Group {
                Button(action: {
                    self.dismissCallback?()
                }, label: {
                        Text("Dismiss")
                }).padding()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct RandomGeneratorFromTableView_Previews: PreviewProvider {
    static var previews: some View {
        RandomGeneratorFromTableView(data: "The regal Stave \nthe food is disgusting.\n", generatorTitle: "TEST", dismissCallback: {}, generator: nil)
    }
}
