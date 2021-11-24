//
//  GeneratorTypeSelectionView.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 11/11/21.
//

import SwiftUI

struct GeneratorTypeSelectionView: View {
    var body: some View {
        NavigationView {
            
            VStack {
                NavigationLink(destination: NameGeneratorSelection()) {
                    Text("Name Generators")
                        .frame(width: UIScreen.main.bounds.width * 0.66, height: UIScreen.main.bounds.width * 0.66, alignment: .center)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(10)
                        .padding()
                }
                NavigationLink(destination: RandomGeneratorSelectionView()) {
                    Text("Random Generators")
                        .frame(width: UIScreen.main.bounds.width * 0.66, height: UIScreen.main.bounds.width * 0.66, alignment: .center)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("Back")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GeneratorTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        GeneratorTypeSelectionView()
    }
}
