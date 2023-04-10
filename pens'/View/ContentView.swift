//
//  ContentView.swift
//  pens'
//
//  Created by Lee Jeong Woo on 2023/03/13.
//

import SwiftUI

struct ContentView: View {
   
    var body: some View {
            NavigationView{
                VStack (spacing: 0){
                    //StartImage
                    Image(systemName: "pencil.line")
                        .font(.system(size:140))
                    Text("Pens'")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    //login
                    NavigationLink(destination:LoginView(), label:{
                        HStack{
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
                    //singup
                    NavigationLink(destination:ResisterView(), label:{
                        HStack{
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.sizeCategory, .medium)
    }
}
