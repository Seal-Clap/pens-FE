//
//  GroupDeleteUser.swift
//  pens'
//
//  Created by 신지선 on 2023/05/02.
//

import Foundation
import Alamofire

enum GroupAPIError: Error {
    case serverError
    case unknownError
}

class LeaveGroup: ObservableObject {
    func leaveGroup(groupId: Int, userId: Int, completion: @escaping (Result<Void, GroupAPIError>) -> Void) {
        guard let url = URL(string: APIContants.groupDeleteUserURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["groupId": groupId, "userId": userId])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                completion(.failure(.serverError))
                return
            }

            if let data = data, let apiResponse = try? JSONDecoder().decode(APIResponse.self, from: data) {
                if httpResponse.statusCode == 200 && apiResponse.success {
                    completion(.success(()))
                } else {
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.unknownError))
            }
        }.resume()
    }

    struct APIResponse: Codable {
        let success: Bool
        let message: String
    }

}

func delete(_ group: GroupElement, _ groups: [GroupElement], _ userId: Int) {
    let parameters = ["groupId": group.groupId, "userId": userId]
    print("delete\(group.groupId)")
    AF.request(APIContants.groupDeleteUserURL,
        method: .post,
        parameters: parameters,
        encoding: JSONEncoding(options: [])
    ).responseJSON { (response) in
        print(response)
    }
}
