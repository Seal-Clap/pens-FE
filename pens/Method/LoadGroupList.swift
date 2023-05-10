//
//  LoadGroupList.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/10.
//

import Foundation
import Alamofire


struct GroupElement: Codable, Identifiable{
    let id = UUID()
    let groupId: Int
    let groupName: String

    enum CodingKeys: String, CodingKey {
        case groupId = "groupId"
        case groupName = "groupName"
    }
}



func getGroups(completion: @escaping ([GroupElement]) -> (), _ userId: Int?) {
    guard let userId = userId else { return }

    let parameters: [String: Any] = ["userId": userId]

    AF.request(APIContants.usersGroupsURL, method: .get, parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).responseDecodable(of: [GroupElement].self) { (response) in
        guard let groups = response.value else { return }
        completion(groups)
    }
}

