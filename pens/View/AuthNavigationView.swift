//
//  File.swift
//  pens'
//
//  Created by 최진현 on 2023/04/11.
//

import SwiftUI

struct AuthNavigationView: View {
    @Binding var loginState: Bool?
    @State private var isRegistered = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // StartImage
                Image(systemName: "pencil.line")
                    .font(.system(size: 140, weight: .light))
                    .fontDesign(.serif)
                HStack{
                    Text("Pens'")
                        .font(.title)
                        .fontWeight(.light)
                }
                // login
                NavigationLink(destination: LoginView(loginState: $loginState), label: {
                    HStack {
                        Spacer()
                        Text("로그인").fontWeight(.light)
                        Spacer()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 250)
                }).padding()
                // singup
                NavigationLink(destination: ResisterView(isRegistered: $isRegistered, showAlert: $showAlert), label: {
                    HStack {
                        Spacer()
                        Text("회원가입").fontWeight(.light)
                        Spacer()
                    }
                    .padding()
                    .background(Color.cyan)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 250)
                })
            }
        }
    }
}
