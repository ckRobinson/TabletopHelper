//
//  ContentView.swift
//  CSC690_SwiftUI
//
//  Created by Cameron Robinson on 10/25/21.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            ZStack {
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    FloatingMenu()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
