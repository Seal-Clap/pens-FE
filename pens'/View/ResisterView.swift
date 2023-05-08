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
    @State var pwdConfirm : String = ""
    //회원가입 버튼 클릭시
    @Binding var isRegistered: Bool
    @Binding var showAlert: Bool
    
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
                    SecureField("비밀번호 확인", text: $pwdConfirm).keyboardType(.default)
                })
                //button
                Section{
                    Button(action: {
                        //register(email: emailInput, pwd: pwdInput, name: nameInput)//함수 호출
                        pwdCheck(email: emailInput, pwd: pwdInput, name: nameInput, pwdConfirm: pwdConfirm, isRegistered: $isRegistered, showAlert: $showAlert)
                    }, label: {
                        Text("회원가입")
                    })
                }
            }
        }.navigationTitle("Sign Up")
            .alert(isPresented: $showAlert) {
                if isRegistered {
                    return Alert(title: Text("회원가입 완료"), message: Text("회원가입이 완료되었습니다."), dismissButton: .default(Text("확인")))
                } else {
                    return Alert(title: Text("회원가입 실패"), message: Text("비밀번호가 일치하지 않습니다."), dismissButton: .default(Text("확인")))
                }
            }
    }
    
}
struct ResisterView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyIsRegistered = Binding.constant(false)
        let dummyShowAlert = Binding.constant(false)
        return ResisterView(isRegistered: dummyIsRegistered, showAlert: dummyShowAlert)
    }
}

