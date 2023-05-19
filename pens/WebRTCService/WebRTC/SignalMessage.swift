//
//  SignalMessage.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import WebRTC

enum SignalMessage {
    case none
    case ice(_ message: RTCIceCandidate)
    case answer(_ message: RTCSessionDescription)
    case offer(_ message: RTCSessionDescription)
    case bye
    
    static func from(message: String) -> SignalMessage {
        if let data = message.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            if dict.keys.contains("data"),
               let messageStr = dict["data"] as? String,
               let messageData = messageStr.data(using: .utf8),
               let messageDict = try? JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] {
                
                if let type = dict["type"] as? String {
                    
                    if type == "ice",
//                       let candidateDict = messageDict["candidate"] as? [String: Any],
//                       let candidate = RTCIceCandidate.candidate(from: candidateDict) {
//                        return .ice(candidate)
                        let candidate = RTCIceCandidate.candidate(from: messageDict) {
                        return .ice(candidate)
                    } else if type == "answer",
                              let sdp = messageDict["sdp"] as? String {
                        return .answer(RTCSessionDescription(type: .answer, sdp: sdp))
                    } else if type == "offer",
                              let sdp = messageDict["sdp"] as? String {
                        return .offer(RTCSessionDescription(type: .offer, sdp: sdp))
                    } else if type == "bye" {
                        return .bye
                    }
                }
            }
        }
        return .none
    }
}

extension RTCSessionDescription {
    func jsonData() -> Data? {
        let typeStr = self.type.rawValue
        let dict: [String: Any] = ["type": typeStr, "sdp": self.sdp]
        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }
}

extension RTCIceCandidate {
    func jsonData() -> Data? {
        let dict: [String: Any] = ["type": "ice", "label": "\(self.sdpMLineIndex)", "id": self.sdpMid, "candidate": self.sdp]
        return try? JSONSerialization.data(withJSONObject: dict, options: [])
    }
    
//    convenience init?(dict: [String: Any]) {
//        guard let sdp = dict["ice"] as? String,
//              let sdpMid = dict["id"] as? String,
//              let labelStr = dict["label"] as? String,
//              let label = Int32(labelStr) else { return nil }
//        self.init(sdp: sdp, sdpMLineIndex: label, sdpMid: sdpMid)
//    }
    
    static func candidate(from: [String: Any]) -> RTCIceCandidate? {
        let sdp = from["candidate"] as? String
        let sdpMid = from["id"] as? String
        let labelStr = from["label"] as? String
        let label = (from["label"] as? Int32) ?? 0
        
        return RTCIceCandidate(sdp: sdp ?? "", sdpMLineIndex: Int32(labelStr ?? "") ?? label, sdpMid: sdpMid)
    }
}


