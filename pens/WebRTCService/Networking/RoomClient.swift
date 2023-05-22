//
//  RoomClient.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import Alamofire


enum RoomResponseError: Error {
    case full
}

struct RoomClient {

    func disconnect(roomID: String, completion: @escaping (() -> Void)) {

        AF.request(leaveURL(roomID: roomID), method: .post).response { _ in
            completion()
        }
    }

    func sendMessage(_ message: Data, roomId: String, type: String, receiver: String, websocket: WebSocketClient, completion: @escaping (() -> Void)) {
        let stringMessage = String(data: message, encoding: .utf8)
        let jsonData: [String: Any] = ["roomId": roomId, "type": type, "receiver": receiver, "data": stringMessage]
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData)
            websocket.send(data: data)
        } catch let error {
            print("JSONSerialization error: \(error)")
        }
        completion()
    }
}


// MARK: URL Path
extension RoomClient {
    func roomURL(roomID: String) -> String {
        let base = Config.default.signalingServer + "/signal"
        return base
    }
    func leaveURL(roomID: String) -> String {
        let base = Config.default.signalingServer + "/signal"
        return base + "?roomId=\(roomID)"
    }
    func messageURL(roomID: String) -> String {
        let base = Config.default.signalingServer + "/signal"
        return base + "?roomId=\(roomID)"
    }
}
