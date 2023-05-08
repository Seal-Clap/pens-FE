//
//  Auth.swift
//  pens'
//
//  Created by 박상준 on 2023/05/07.
//

import Foundation

class Auth: ObservableObject {
    func logOut() {
        deleteToken()
    }
}
