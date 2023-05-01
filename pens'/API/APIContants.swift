//
//  APIContants.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation

struct APIContants{
    //고정ip
    static let baseURL = "http://13.125.106.204:8080"
    //login
    static let loginURL = baseURL + "/login"
    //register
    static let registerURL = baseURL + "/register"
    //login token
    static let tokenURL = baseURL + "/identity"
}
