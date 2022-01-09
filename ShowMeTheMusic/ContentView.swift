//
//  ContentView.swift
//  ShowMeTheMusic
//
//  Created by Angelo Chaves on 2022-01-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Add the widget in the notification center.")
            Text("You may quit this app.")
        }
        .font(.title)
        .padding()
        .frame(width: 400, height: 200, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
