    //
    //  ContentView.swift
    //  pens'
    //
    //  Created by Lee Jeong Woo on 2023/03/13.
    //

import SwiftUI

struct ContentView: View {
    @State private var loginState = false
    var body: some View {
        if !loginState {
            AuthNavigationView(loginState: $loginState)
        }
        else {
            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.sizeCategory, .medium)
    }
}
