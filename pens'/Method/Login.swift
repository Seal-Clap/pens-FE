//
//  Login.swift
//  pens'
//
//  Created by 신지선 on 2023/04/10.
//

import Foundation

struct LoginRequest: Codable {
    let userEmail: String
    let userPassword: String
}

enum LoginError: String, Codable {
    case invalidEmail = "INVALID_EMAIL"
    case invalidPassword = "INVALID_PASSWORD"
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let token :  String?
    let error: LoginError?
}

func login(email: String, password: String, completion: @escaping (Bool, String, String?) -> Void) {
    guard let url = URL(string: APIContants.loginURL) else {
        completion(false, "Invalid URL", nil)
        return
    }
    
    let loginData = LoginRequest(userEmail: email, userPassword: password)
    guard let httpBody = try? JSONEncoder().encode(loginData) else {
        completion(false, "Error encoding data", nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = httpBody
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(false, "Network error", nil)
            return
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            completion(loginResponse.success, loginResponse.message, loginResponse.token)
            print(loginResponse.message)
            if let error = loginResponse.error {
                switch error {
                case .invalidEmail:
                    completion(false, "등록된 이메일이 없습니다.", nil)
                case .invalidPassword:
                    completion(false, "이메일과 비밀번호가 일치하지 않습니다.", nil)
                }
            } else {
                completion(loginResponse.success, loginResponse.message, loginResponse.token)
            }
        } catch {
            completion(false, "Error decoding response", nil)
        }
    }
    task.resume()
}
