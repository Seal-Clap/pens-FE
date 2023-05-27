    //
    //  ContentView.swift
    //  pens'
    //
    //  Created by Lee Jeong Woo on 2023/03/13.
    //

import SwiftUI

struct ContentView: View {
    @State private var isLoading: Bool = true
    @State public var loginState: Bool? = loadToken() != nil ? true : false

    var body: some View {
        ZStack{
            //앱 화면
            if loginState == false {
                AuthNavigationView(loginState: $loginState).onAppear {
                    checkTokenAndLogin { result in
                        loginState = result
                    }
                }
            } else if loginState == true {
                HomeView(loginState: $loginState, viewModel: AudioCallViewModel())
            }
            //런치 스크린
            if isLoading {
                launchScreenView.transition(.opacity).zIndex(1)
            }
            //onAppear of Zstack
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                withAnimation{
                    isLoading.toggle()
                }
            })
        }
    }
}
extension ContentView {
    var launchScreenView: some View {
        ZStack(alignment: .center) {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.white]),
                                        startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
            VStack{
                Image("LaunchImage").resizable()
//                Image(systemName: "pencil.line").font(.system(size: 450, weight: .ultraLight)).foregroundColor(.blue)
//                Text("pens'").font(.system(size: 75, weight: .ultraLight))
//                    .fontDesign(.monospaced).foregroundColor(.cyan)
            }
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.sizeCategory, .medium)
    }
}
