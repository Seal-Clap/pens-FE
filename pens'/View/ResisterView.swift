//
//  ResisterView.swift
//  pens'
//
//  Created by 박상준 on 2023/03/24.
//

import SwiftUI


struct ResisterView: View {
    @State var nameInput : String = ""
    @State var emailInput : String = ""
    @State var pwdInput : String = ""
    
    var body: some View {
        VStack{
            Form{
                //이름
                Section(header: Text("이름"), content:{
                    TextField("홍길동", text: $nameInput).keyboardType(.default).autocapitalization(.none)
                })
                //이메일
                Section(header: Text("이메일"), content:{
                    TextField("email@email.com", text: $emailInput).keyboardType(.emailAddress).autocapitalization(.none)
                })
                //비밀번호
                Section(header: Text("비밀번호"), content:{
                    SecureField("비밀번호", text: $pwdInput).keyboardType(.default)
                    SecureField("비밀번호 확인", text: $pwdInput).keyboardType(.default)
                })
                //button
                Section{
                    Button(action: {
                        register(email: emailInput, pwd: pwdInput, name: nameInput) //함수 호출
                    }, label: {
                        Text("회원가입")
                    })
                }
            }
        }.navigationTitle("Sign Up")
    }
    
}

struct ResisterView_Previews: PreviewProvider {
    static var previews: some View {
        ResisterView()
    }
}
