    //
    //  ContentView.swift
    //  pens'
    //
    //  Created by Lee Jeong Woo on 2023/03/13.
    //

import SwiftUI

struct ContentView: View {
    @State public var loginState: Bool? = loadToken() != nil ? true : false
    var body: some View {
        if loginState == false {
            AuthNavigationView(loginState: $loginState).onAppear {
                checkTokenAndLogin { result in
                    loginState = result
                }
            }
        } else if loginState == true {
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
