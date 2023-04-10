//
//  Login.swift
//  pens'
//
//  Created by 신지선 on 2023/04/10.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
}

func login(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
    guard let url = URL(string: APIContants.loginURL) else {
        completion(false, "Invalid URL")
        return
    }
    
    let loginData = LoginRequest(email: email, password: password)
    guard let httpBody = try? JSONEncoder().encode(loginData) else {
        completion(false, "Error encoding data")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = httpBody
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(false, "Network error")
            return
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            completion(loginResponse.success, loginResponse.message)
            print(loginResponse.message)
        } catch {
            completion(false, "Error decoding response")
        }
    }
    task.resume()
}
