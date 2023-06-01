import Foundation
import SwiftUI
import WebRTC


struct WebSocketMessage: Decodable {
    let type: String
    let sender: String?
    let receiver: String?
    let roomId: String
    let data: String?

}

class AudioCallViewModel: ObservableObject {
    @Published var signalReceived = false

    var _roomClient: RoomClient?

    // MARK: Room
//    var _roomInfo: JoinResponseParam?
    var _roomId: String = ""
    var _senderQueue: [String] = [String]()
    var _sender: String = ""
    var _webSocket: WebSocketClient?
    var _messageQueue = [String]()

    //MARK: WebRTC
    var _webRTCClient: WebRTCClient?

    func connectRoom(roomID: String) -> Void {
        dLog("connectToRoom");
        prepare(roomId: roomID);
        join(roomID: roomID)
    }

    private func prepare(roomId: String) {
        _roomClient = RoomClient();
        _webSocket = WebSocketClient();
        _webRTCClient = WebRTCClient();
        _roomId = roomId
    }

    func clear() {
        _roomClient = nil
        _webRTCClient = nil
        _webSocket = nil
    }
}

extension AudioCallViewModel {
    func join(roomID: String) -> Void {
        guard let _roomClient = _roomClient else {
            return
        }
        connectToWebSocket(roomId: roomID)
    }

    func startVoiceChat() {
        _webRTCClient?.createOffer()
    }

    func disconnect() -> Void {
        let roomID = _roomId
        guard let roomClient = _roomClient,
            let webSocket = _webSocket,
            let webRTCClient = _webRTCClient else { return }

        roomClient.disconnect(roomID: roomID) { [weak self] in
            self?._roomId = ""
            self?._senderQueue = []
        }

        let message = ["type": "bye"]

        if let data = message.JSONData {
            webSocket.send(data: data)
        }
        webSocket.delegate = nil
        webRTCClient.disconnect()
        webSocket.disconnect()

        clear()
    }

    func drainMessageQueue() {
        guard let webSocket = _webSocket,
            webSocket.isConnected,
            let webRTCClient = _webRTCClient else {
            return
        }

        for message in _messageQueue {
            processSignalingMessage(message)
        }
        _messageQueue.removeAll()
        webRTCClient.drainMessageQueue()
    }

    func processSignalingMessage(_ message: String) -> Void {
        guard let webRTCClient = _webRTCClient else { return }
        let signalMessage = SignalMessage.from(message: message)
        switch signalMessage {
        case .`init`(let sender):
            _sender = sender
            webRTCClient.createOffer()
            signalReceived = !signalReceived
            print("debug: signalReceived Toggled: \(signalReceived)")
        case .ice(let candidate):
            webRTCClient.handleCandidateMessage(candidate)
            dLog("Receive candidate")
        case .answer(let answer):
            webRTCClient.handleRemoteDescription(answer)
            dLog("Recevie Answer")
        case .offer(let offer, let sender):
            self._senderQueue.append(sender)
            webRTCClient.handleRemoteDescription(offer)
            dLog("Recevie Offer")
        case .bye:
            signalReceived = !signalReceived
            print("debug: signalReceived Toggled: \(signalReceived)")
//            disconnect()
        default:
            break
        }
    }

    func sendSignalingMessage(_ message: Data, type: String, receiver: String) {
        guard let roomClient = _roomClient,
            let webSocket = _webSocket
            else { return }
        roomClient.sendMessage(message, roomId: _roomId, type: type, receiver: receiver, websocket: webSocket) {

        }
    }


}

//MARK: webSocketClientDelegate
extension AudioCallViewModel: WebSocketClientDelegate {
    func connectToWebSocket(roomId: String) -> Void {
        guard let webSocketURL = URL(string: Config.default.signalingServer + "/signal?roomId=" + roomId) else {
            return
        }
        guard let webSocket = _webSocket else {
            return
        }
        webSocket.delegate = self
        debugPrint(webSocketURL)
        webSocket.connect(url: webSocketURL)
    }



    func webSocketDidConnect(_ webSocket: WebSocketClient) {
        guard let webRTCClient = _webRTCClient else { return }
        webRTCClient.delegate = self
        drainMessageQueue()

    }

    func webSocketDidDisconnect(_ webSocket: WebSocketClient) {
        webSocket.delegate = nil
    }

    func webSocket(_ webSocket: WebSocketClient, didReceive data: String) {
        processSignalingMessage(data)
        _webRTCClient?.drainMessageQueue()
    }
}

//MARK: WebRTCClientDelegate
extension AudioCallViewModel: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, sendData data: Data, type: String) {
//        _sender = _senderQueue.remove(at: 0)
        switch type {
        case "offer":
            sendSignalingMessage(data, type: type, receiver: _sender)
        case "answer":
            _sender = _senderQueue.remove(at: 0)
            sendSignalingMessage(data, type: type, receiver: _sender)
        default:
            sendSignalingMessage(data, type: type, receiver: _sender)
        }
        
    }

    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        guard let message = candidate.jsonData() else { return }
//        self._webRTCClient?.delegate?.webRTCClient(_webRTCClient!, sendData: message, type: "ice", receiver: _sender)
        sendSignalingMessage(message, type: "ice", receiver: _sender)
    }

    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        dLog(state)
    }

    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        dLog(data)
    }
}

