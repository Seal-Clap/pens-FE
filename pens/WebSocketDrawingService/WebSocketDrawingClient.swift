//
//  WebSocketClient.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import SocketRocket

protocol WebSocketDrawingClientDelegate: AnyObject {
    func webSocketDidConnect(_ webSocket: WebSocketDrawingClient)
    func webSocketDidDisconnect(_ webSocket: WebSocketDrawingClient)
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: String)
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: Data)
}

class WebSocketDrawingClient: NSObject {
    weak var delegate: WebSocketDrawingClientDelegate?
    var socket: SRWebSocket?
    
    var isConnected: Bool {
        return socket != nil
    }
    
    func connect(url: URL) {
        socket = SRWebSocket(url: url)
        print("debug2 \(url)")
        socket?.delegate = self
        socket?.open()
    }
    
    func disconnect() {
        socket?.close()
        socket = nil
        self.delegate?.webSocketDidDisconnect(self)
    }
    
    func send(data: Data) {
        guard let socket = socket else {
            dLog("Check Socket connection")
            return
        }
        
        dLog(data.prettyPrintedJSONString)
        guard let stringData = String(data: data, encoding: .utf8) else {
            return
        }
        socket.send(stringData)
    }
    
    func sendBytes(data: Data) {
        guard let socket = socket else {
            dLog("Check Socket connection")
            return
        }
        socket.send(data)
    }
}

extension WebSocketDrawingClient: SRWebSocketDelegate {
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessageWith data: Data) {
        delegate?.webSocket(self, didReceive: data)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: String) {
        dLog(message)
        delegate?.webSocket(self, didReceive: message)
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        delegate?.webSocketDidConnect(self)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        debugPrint("did Fail to connect websocket")
        debugPrint(error)
        self.disconnect()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        debugPrint("did close websocket")
        self.disconnect()
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
            delegate?.webSocket(self, didReceive: pongPayload)
    }
}

