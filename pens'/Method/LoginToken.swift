//
//  LoginToken.swift
//  pens'
//
//  Created by 박상준 on 2023/04/16.
//

import Foundation

struct UserIdResponse: Codable {
    let userId: Int
}

func saveToken(_ token: String) {
    UserDefaults.standard.set(token, forKey: "userToken")
}
func getToken() -> String? {
    return UserDefaults.standard.string(forKey: "userToken")
}

