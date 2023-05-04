//
//  File.swift
//  pens'
//
//  Created by 최진현 on 2023/04/11.
//

import SwiftUI

struct AuthNavigationView: View {
    @Binding var loginState: Bool?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // StartImage
                Image(systemName: "pencil.line")
                    .font(.system(size: 140))
                Text("Pens'")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                // login
                NavigationLink(destination: LoginView(loginState: $loginState), label: {
                    HStack {
                        Spacer()
                        Text("로그인")
                        Spacer()
                    }
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 250)
                }).padding()
                // singup
                NavigationLink(destination: ResisterView(), label: {
                    HStack {
                        Spacer()
                        Text("회원가입")
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(width: 250)
                })
            }
        }
    }
}
