//
//  LoginView.swift
//  pens'
//
//  Created by 박상준 on 2023/03/24.
//
import Foundation
import SwiftUI

struct LoginView: View {
    
    @State var emailInput : String = ""
    @State var pwdInput : String = ""
    
    var body: some View {
        VStack{
            Form{
                Section(header: Text("로그인 정보"), content:{
                    //email
                    TextField("email@email.com", text: $emailInput).keyboardType(.emailAddress).autocapitalization(.none)
                    //password
                    SecureField("password", text: $pwdInput).keyboardType(.default)
                })
                Section{
                    Button(action: {
                        print("로그인 버튼")
                    }, label: {
                        Text("로그인")
                    })
                }
            }
        }.navigationTitle("Sign In")
    }
}
#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
#endif
