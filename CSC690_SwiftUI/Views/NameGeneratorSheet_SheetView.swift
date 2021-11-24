//
//  SwiftUIView.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 11/12/21.
//

import SwiftUI

struct NameGeneratorSheetView: View {
    
    @State var name: String = " "
    let generatorTitle: String
    let generator: MarkovChain?
    
    let dismissCallback: () -> Void
    
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
                    Text(self.name)
                        .frame(minWidth: 0, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .padding()
                        .overlay(
                            Rectangle()
                                .stroke(lineWidth: 2)
                                .accentColor(.black)
                                .padding(.horizontal)
                        )
                        
                    HStack {
                        Button(action: {
                            if let g = generator {
                                self.name = g.generateWord(order: .second)
                            }
                            else {
                                self.name = "No generator available."
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
                            UIPasteboard.general.string = self.name
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
                    dismissCallback()
                }, label: {
                        Text("Dismiss")
                }).padding()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct NameGeneratorSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NameGeneratorSheetView(generatorTitle: "TEST", generator: nil, dismissCallback: {} )
    }
}
