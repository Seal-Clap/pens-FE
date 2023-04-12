//
//  Register.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation

func register(email: String, pwd: String, name: String){
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
    
    print("")
    print("====================================")
    print("[requestPOST : http post 요청 실시]")
    print("url : ", requestURL)
    print("====================================")
    print("")
    let _: Void = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
        // [error가 존재하면 종료]
        guard error == nil else {
            print("")
            print("====================================")
            print("[requestPOST : http post 요청 실패]")
            print("fail : ", error?.localizedDescription ?? "")
            print("====================================")
            print("")
            return
        }
    }.resume()
}
