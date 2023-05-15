//
//  InviteGroup.swift
//  pens'
//
//  Created by 박상준 on 2023/05/07.
//

import Foundation
import Alamofire

struct GroupListResponse: Codable {
    let groups: [GroupIdResponse]
}
struct GroupIdResponse: Codable {
    let groupId: Int
    let groupName: String
}

struct InviteGroupResponse: Codable {
    let success: Bool
    let message: String
}

enum InviteGroupError: Error {
    case invalidURL
    case encodingError
    case networkError
    case decodingError
}

func getGroupId(userId: Int, groupId: Int, completion: @escaping (Result<Int, Error>) -> Void) {
    let urlString = "\(APIContants.usersGroupsURL)?userId=\(userId)"
    let url = URL(string: urlString)!
    
    AF.request(url, method: .get).responseDecodable(of: [GroupIdResponse].self) { response in
        switch response.result {
        case .success(let groupIdResponses):
            if let groupIdResponse = groupIdResponses.first(where: { $0.groupId == groupId }) {
                completion(.success(groupIdResponse.groupId))
            } else {
                completion(.failure(NSError(domain: "Group not found", code: -1, userInfo: nil)))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

func inviteGroup(groupId: Int, userEmail: String, completion: @escaping (Result<InviteGroupResponse, InviteGroupError>) -> Void) {
    let url = URL(string: APIContants.groupInviteURL)!
    let parameters: [String: Any] = [
        "groupId": groupId,
        "userEmail": userEmail
    ]
    
    AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: InviteGroupResponse.self) { response in
        switch response.result {
        case .success(let inviteResponse):
            completion(.success(inviteResponse))
        case .failure:
            completion(.failure(.networkError))
        }
    }
}
