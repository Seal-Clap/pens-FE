//
//  Config.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation

fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

fileprivate let defaultSignalingServer = "ws://13.209.120.19:8080/ws/signal"

struct Config {
    let signalingServer: String
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServer: defaultSignalingServer,
                                  webRTCIceServers: defaultIceServers)
}
