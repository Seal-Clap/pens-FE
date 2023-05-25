//
//  LoginView.swift
//  pens'
//
//  Created by 박상준 on 2023/03/24.
//
import Foundation
import SwiftUI

struct LoginView: View {
    @Binding var loginState: Bool?
    @State var emailInput : String = ""
    @State var pwdInput : String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
       
    var body: some View {
        VStack{
            Form{
                Section(header: Text("로그인 정보"), content:{
                    TextField("email@email.com", text: $emailInput).keyboardType(.emailAddress).autocapitalization(.none)
                    SecureField("password", text: $pwdInput).keyboardType(.default)
                })
                Section{
                    Button(action: {
                        if isValidEmail(emailInput) {
                            login(email: emailInput, password: pwdInput) { success, message, token in
                                DispatchQueue.main.async {
                                    if success {
                                        if let token = token {
                                            saveToken(token)
                                            print("Token saved: \(token)")
                                        }
                                        loginState = true
                                    } else {
                                        self.alertMessage = message
                                        self.showAlert = true
                                    }
                                }
                            }
                        } else {
                            self.alertMessage = "유효하지 않은 이메일 주소입니다."
                            self.showAlert = true
                        }
                    }, label: {
                        Text("로그인")
                    }).alert(isPresented: $showAlert) {
                        Alert(title: Text("로그인 실패"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                    }
                }
            }
        }.navigationBarTitle("로그인")
            .font(.system(size: 15, weight: .light))
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    @State static private var loginState: Bool? = false
    
    static var previews: some View {
        LoginView(loginState: $loginState)
    }
}
#endif
