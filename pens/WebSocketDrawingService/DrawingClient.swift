//
//  RoomClient.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import Alamofire


enum DrawingResponseError: Error {
    case full
}
struct DrawingClient {

    func disconnect(roomID: String, completion: @escaping (() -> Void)) {

        AF.request(leaveURL(roomID: roomID), method: .post).response { _ in
            completion()
        }
    }

    func sendDrawingData(_ drawingData: Data, roomId: String, type: String, websocket: WebSocketDrawingClient, completion: @escaping (() -> Void)) {
        //let stringMessage = String(data: message, encoding: .utf8)
        
        websocket.sendBytes(data: drawingData)
        
        completion()
    }
}


// MARK: URL Path
extension DrawingClient {
    func roomURL(roomID: String) -> String {
        let base = DrawingConfig.default.drawingServer + "/draw"
        return base + "?roomId=\(roomID)"
    }
    func leaveURL(roomID: String) -> String {
        let base = DrawingConfig.default.drawingServer + "/draw"
        return base + "?roomId=\(roomID)"
    }
    func messageURL(roomID: String) -> String {
        let base = DrawingConfig.default.drawingServer + "/draw"
        return base + "?roomId=\(roomID)"
    }
}
