//
//  Login.swift
//  pens'
//
//  Created by 신지선 on 2023/04/10.
//

import Foundation
import SwiftUI
import Alamofire

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
    
    let parameters: [String: Any] = [
        "userEmail": email,
        "userPassword": password
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
        switch response.result {
        case .success:
            guard let data = response.data else {
                completion(false, "No data received", nil)
                return
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                let userId = loginResponse.userId
                print("+++++++++++++++++++++++ userId : \(userId) ++++++++++++++++++++++++++++++")
                saveUserId(userId)
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
                    if let token = loginResponse.token {
                        saveToken(token)
                    }
                }
            } catch {
                completion(false, "Error decoding response", nil)
            }
        case .failure(let error):
            print("Request failed: \(error.localizedDescription)")
            completion(false, "Network error", nil)
        }
    }
}
//토큰 로그인
func tokenLogin(token: String, completion: @escaping (Bool, String) -> Void) {
    guard let url = URL(string: APIContants.tokenURL) else {
        completion(false, "Invalid URL")
        return
    }

    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(token)"
    ]

    AF.request(url, method: .get, headers: headers).responseJSON { response in
        switch response.result {
        case .success:
            guard let data = response.data else {
                completion(false, "No data received")
                return
            }
            
            do {
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                completion(loginResponse.success, loginResponse.message)
            } catch {
                completion(false, "Error decoding response")
            }
        case .failure(let error):
            print("Request failed: \(error.localizedDescription)")
            completion(false, "Network error")
        }
    }
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

func getUserNameByUserId(userId: Int?, completion: @escaping (String?) -> Void) {
    AF.request("\(APIContants.baseURL)/users/\(userId!)/name", method: .get).responseString { response in
            switch response.result {
            case .success(let userName):
                completion(userName)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
}
