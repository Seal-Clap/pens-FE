//
//  RoomClient.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import Alamofire

enum JoinStatus: String, Decodable {
    case FULL
    case SUCCESS
}

struct JoinResponse: Decodable {
    let result: JoinStatus
    let params: JoinResponseParam
}

struct JoinResponseParam: Decodable {
    let room_id: String?
    let wss_url: String?
    let wss_post_url: String?
    let client_id: String?
    let is_initiator: String?
    let messages: [String]?
}

struct tempParam: Decodable {
    let type: String
    let sender: String?
    let receiver: String?
    let roomId: String?
    let data: Data?
}

enum RoomResponseError: Error {
    case full
}

struct RoomClient {
    
    func join(roomID:String,completion: @escaping ((_ response: JoinResponseParam?, _ error: Error?) -> Void)) -> Void {
        let temp: tempParam = tempParam(type: "init", sender: "1", roomId: "1")
        AF.request(roomURL(roomID: roomID), method: .post, parameters: temp, encoder: JSONParameterEncoder(encoder: <#T##JSONEncoder#>)).responseDecodable(of: JoinResponse.self) { response in
            
            switch response.result {
            case .success(let result):
                if result.result == .SUCCESS {
                    completion(result.params, nil)
                } else if result.result == .FULL {
                    completion(nil, RoomResponseError.full)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    func disconnect(roomID: String, userID: String, completion: @escaping (() -> Void)) {
        
        AF.request(leaveURL(roomID: roomID, userID: userID), method: .post).response { _ in
            completion()
        }
    }
    
    func sendMessage(_ message: Data, roomID: String, userID: String, completion: @escaping (() -> Void)) {
        
        AF.request(messageURL(roomID: roomID, userID: userID), method: .post, parameters: ["message": message], encoding: JSONEncoding.default).response { response in
            if let data = response.data {
                dLog("\(data.prettyPrintedJSONString)")
            } else if let error = response.error {
                dLog(error)
            }
            completion()
        }
    }
}

// MARK: URL Path
extension RoomClient {
    func roomURL(roomID: String) -> String {
        let base = Config.default.signalingServer + "/room/"
        return base + "?roomId=\(roomID)"
    }
    func leaveURL(roomID: String, userID: String) -> String {
        let base =  Config.default.signalingServer + "/leave/"
        return base + "\(roomID)/\(userID)"
    }
    func messageURL(roomID: String, userID: String) -> String {
        let base =  Config.default.signalingServer + "/message/"
        return base + "\(roomID)/\(userID)"
    }
}
