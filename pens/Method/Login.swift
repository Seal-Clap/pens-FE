//
//  Login.swift
//  pens'
//
//  Created by 신지선 on 2023/04/10.
//

import Foundation
import SwiftUI

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
    let userId : Int
}
//로그인
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
            let userId = loginResponse.userId
            print("+++++++++++++++++++++++ userId : \(userId) ++++++++++++++++++++++++++++++")
            saveUserId(userId)
            completion(loginResponse.success, loginResponse.message, loginResponse.token)
            print(loginResponse.message)
            
            //유효성 검사
            if let error = loginResponse.error {
                switch error {
                case .invalidEmail:
                    completion(false, "등록된 이메일이 없습니다.", nil)
                case .invalidPassword:
                    completion(false, "이메일과 비밀번호가 일치하지 않습니다.", nil)
                }
            } else {
                completion(loginResponse.success, loginResponse.message, loginResponse.token)
                //토큰 처리
                if let token = loginResponse.token {
                    saveToken(token)
                }
            }
        } catch {
            completion(false, "Error decoding response", nil)
        }
    }
    task.resume()
}
//토큰 로그인
func tokenLogin(token: String, completion: @escaping (Bool, String) -> Void) {
    guard let url = URL(string: APIContants.tokenURL) else {
        completion(false, "Invalid URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            completion(false, "Network error")
            return
        }

        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            completion(loginResponse.success, loginResponse.message)
        } catch {
            completion(false, "Error decoding response")
        }
    }
    task.resume()
}
//토큰 확인 -> contentView에서 먼저 확인하여 토큰 로그인 여부 확인해야함
func checkTokenAndLogin(completion: @escaping (Bool?) -> Void){
    
    if let token = getToken() {
        tokenLogin(token: token) { success, message in
            if success {
                // 토큰 로그인 성공 시 처리
                print("토큰 로그인 성공: \(message)")
                completion(true)
            } else {
                // 토큰 로그인 실패 시 처리
                print("토큰 로그인 실패: \(message)")
                //로그인 state처리
                completion(false)
            }
        }
    } else {
        // 저장된 토큰이 없을 경우 로그인 화면 표시
        //로그인 state처리
        completion(false)
    }
}
