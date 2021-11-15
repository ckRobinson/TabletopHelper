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
    
    var body: some View {
        VStack {
            Text(self.generatorTitle)
                .frame(minWidth: 0, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding()
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
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        NameGeneratorSheetView(generatorTitle: "TEST", generator: nil)
    }
}
