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
    @State private var showAlert = false
       @State private var alertMessage = ""
       
       var body: some View {
           VStack{
               Form{
                   Section(header: Text("로그인 정보"), content:{
                       TextField("email@email.com", text: $emailInput).keyboardType(.emailAddress).autocapitalization(.none)
                       SecureField("password", text: $pwdInput).keyboardType(.default)
                   })
                   Section{
                       Button(action: {
                           login(email: emailInput, password: pwdInput) { success, message in
                               DispatchQueue.main.async {
                                   if success {
                                       print("로그인 성공")
                                   } else {
                                       self.alertMessage = message
                                       self.showAlert = true
                                   }
                               }
                           }
                       }, label: {
                           Text("로그인")
                       }).alert(isPresented: $showAlert) {
                           Alert(title: Text("로그인 실패"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                       }
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
