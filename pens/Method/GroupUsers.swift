//
//  GroupUsers.swift
//  pens
//
//  Created by 최진현 on 2023/05/11.
//

import Foundation
import Alamofire


struct UserElement: Codable, Identifiable{
    let id = UUID()
    let userName: String
    let userEmail: String

    enum CodingKeys: String, CodingKey {
        case userName = "userName"
        case userEmail = "userEmail"
    }
}



func getUsers(completion: @escaping ([UserElement]) -> (), _ groupId: Int?) {
    guard let groupId = groupId else { return }
    let parameters: [String: Any] = ["groupId": groupId]
    AF.request(APIContants.groupUsersURL, method: .get, parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).responseDecodable(of: [UserElement].self) { (response) in
        guard let users = response.value else { return }
        completion(users)
    }
}

