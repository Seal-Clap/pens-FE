//
//  Register.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation
import SwiftUI
import Alamofire

func register(email: String, pwd: String, name: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: APIContants.registerURL) else {
        print("Invalid URL")
        return
    }
    
    let parameters: [String: Any] = [
        "userEmail": email,
        "userPassword": pwd,
        "userName": name
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
        switch response.result {
        case .success:
            if let httpResponse = response.response {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        case .failure(let error):
            print("Request failed: \(error.localizedDescription)")
            completion(false)
        }
    }
}

func pwdCheck(email: String, pwd: String, name: String, pwdConfirm: String, isRegistered: Binding<Bool>, showAlert: Binding<Bool>) {
    if pwd == pwdConfirm {
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
