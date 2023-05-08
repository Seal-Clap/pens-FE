//
//  InviteGroup.swift
//  pens'
//
//  Created by 박상준 on 2023/05/07.
//

import Foundation
struct GroupIdResponse : Codable {
    let groupId : Int
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
func getGroupId(completion: @escaping(Result<Int, Error>) -> Void){
    guard let url = URL(string: APIContants.userGroupsURL) else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
            return
        }
        print(String(data: data, encoding: .utf8) ?? "No data")
        do {
            let groupIdResponse = try JSONDecoder().decode(GroupIdResponse.self, from: data)
            print("+++++++++++ groupId : \(groupIdResponse.groupId) +++++++++++++++++++")
            completion(.success(groupIdResponse.groupId))
        } catch {
            completion(.failure(error))
            print("Error getting groupId:", error.localizedDescription)
        }
    }
    task.resume()
}
func inviteGroup(groupId: Int, userEmail: String, completion: @escaping (Result<InviteGroupResponse, InviteGroupError>) -> Void) {
    guard let url = URL(string: APIContants.groupInviteURL) else{
        completion(.failure(.invalidURL))
        return
    }

        let inviteData = ["groupId": String(groupId),"userEmail": userEmail]

        guard let httpBody = try? JSONEncoder().encode(inviteData) else {
            completion(.failure(.encodingError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.networkError))
                return
            }

            do {
                let inviteResponse = try JSONDecoder().decode(InviteGroupResponse.self, from: data)
                completion(.success(inviteResponse))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        task.resume()
}
