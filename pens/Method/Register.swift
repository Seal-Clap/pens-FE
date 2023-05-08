//
//  Register.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation
import SwiftUI

func register(email: String, pwd: String, name: String, completion: @escaping (Bool) -> Void){
    guard let url = URL(string: APIContants.registerURL) else {
        print("Invalid URL")
        return
    }
    
    let items = ["userEmail" : email, "userPassword" : pwd, "userName" : name]
    let jsonData = try! JSONSerialization.data(withJSONObject: items)
    
    // [http 통신 타입 및 헤더 지정 실시]
    var requestURL = URLRequest(url: url)
    requestURL.httpMethod = "POST" // POST
    requestURL.httpBody = jsonData
    requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type") // POST
    
   URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
        // [error가 존재하면 종료]
        guard error == nil else {
            print("++++++++++++++++++++++++++++++++++++++++++++++++")
            print("[requestPOST : http post 요청 실패]")
            print("fail : ", error?.localizedDescription ?? "")
            print("++++++++++++++++++++++++++++++++++++++++++++++++")
            completion(false)
            return
        }
       if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                // 서버 응답이 성공이면 completion 핸들러에 true를 전달합니다.
                completion(true)
            } else {
                // 서버 응답이 성공이 아니면 completion 핸들러에 false를 전달합니다.
                completion(false)
            }
        } else {
            completion(false)
        }
   }.resume()
}
func pwdCheck(email: String, pwd: String, name: String, pwdConfirm: String, isRegistered: Binding<Bool>, showAlert: Binding<Bool>){
    if(pwd == pwdConfirm){
        register(email: email, pwd: pwd, name: name) { success in
            DispatchQueue.main.async {
                isRegistered.wrappedValue = success
                showAlert.wrappedValue = true
            }
        }
    } else {
        DispatchQueue.main.async {
            print("pwd : \(pwd) __________________ pwdCheck : \(pwdConfirm)")
            showAlert.wrappedValue = true
        }
    }
    
}
