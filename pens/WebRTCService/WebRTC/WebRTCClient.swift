//
//  WebRTCClient.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, sendData data: Data, type: String)
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

class WebRTCClient: NSObject {
    static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
    }()

    private let mediaConstraints = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue]
    private var candidateQueue = [RTCIceCandidate]()

    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
//    var localAudioTrack: RTCAudioTrack?
    var remoteAudioTrack: RTCAudioTrack?


    var localStream: RTCMediaStream?
    private var peerConnection: RTCPeerConnection?

    weak var delegate: WebRTCClientDelegate?

    private var hasReceivedSdp = false

    override init() {
        super.init()
        setup()
    }




    func setup() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        let config = generateRTCConfig()
        config.iceServers = [RTCIceServer(urlStrings: Config.default.webRTCIceServers)]
        peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
        self.createMediaSenders()
        self.configureAudioSession()
        self.setAudioEnabled(true)
    }

    func createOffer() {
        self.peerConnection?.offer(for: RTCMediaConstraints(mandatoryConstraints: mediaConstraints, optionalConstraints: nil), completionHandler: { (sdp, error) in
                guard let sdp = sdp else {
                    print("Failed to create offer: \(error?.localizedDescription ?? "")")
                    return
                }

                let sdpDescription = self.extractDesc(desc: sdp)
                self.setLocalSDP(sdpDescription)
            })
    }
    //remote 추가 필요, 안거침
    func receivedOffer(_ remoteSdp: RTCSessionDescription) {
        let sdp = self.extractDesc(desc: remoteSdp)
        self.peerConnection?.setRemoteDescription(sdp, completionHandler: { (error) in
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
                return
            }
            self.createAnswer()
        })
    }

    private func createAnswer() {
        self.peerConnection?.answer(for: RTCMediaConstraints(mandatoryConstraints: mediaConstraints, optionalConstraints: nil), completionHandler: { (sdp, error) in
                guard let sdp = sdp else {
                    print("Failed to create answer: \(error?.localizedDescription ?? "")")
                    return
                }
                let sdpDescription = self.extractDesc(desc: sdp)
                self.setLocalSDP(sdpDescription)
            })
    }

    func receivedAnswer(_ remoteSdp: RTCSessionDescription) {
        let sdp = self.extractDesc(desc: remoteSdp)
        self.peerConnection?.setRemoteDescription(sdp, completionHandler: { (error) in
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
                return
            }
        })
    }




    func disconnect() {
        hasReceivedSdp = false
        peerConnection?.close()
        peerConnection = nil
    }


    private func setLocalSDP(_ sdp: RTCSessionDescription) {
        guard let peerConnection = peerConnection else {
            dLog("Check PeerConnection")
            return
        }

        let sdpDescription = self.extractDesc(desc: sdp)

        peerConnection.setLocalDescription(sdpDescription, completionHandler: { (error) in
            if let error = error {
                debugPrint(error)
            }
        })
        guard let jsonData = sdpDescription.jsonData() else { return }
        switch sdpDescription.type {
        case .offer:
            self.delegate?.webRTCClient(self, sendData: jsonData, type: "offer")
        case .answer:
            self.delegate?.webRTCClient(self, sendData: jsonData, type: "answer")
        default:
            dLog("type not define")
        }

//            self.delegate?.webRTCClient(self, sendData: data)
        //                    WebSocketClient().send(data: jsonData)
        dLog("Send Local SDP")
    }
}



// audio
extension WebRTCClient {
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }



    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
}


// MARK: Preparing parts.
extension WebRTCClient {
    private func generateRTCConfig() -> RTCConfiguration {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: Config.default.webRTCIceServers)]
        config.sdpSemantics = RTCSdpSemantics.unifiedPlan

        return config
    }

    private func createMediaSenders() {
        guard let peerConnection = peerConnection else {
            dLog("Check PeerConnection")
            return
        }
        let streamId = "stream"
        let audioTrack = self.createAudioTrack()
        peerConnection.add(audioTrack, streamIds: [streamId])
    }
}


// MARK: Message Handling
extension WebRTCClient {
    func handleCandidateMessage(_ candidate: RTCIceCandidate) {
        candidateQueue.append(candidate)
    }

    func handleRemoteDescription(_ desc: RTCSessionDescription) {
        guard let peerConnection = peerConnection else {
            dLog("Check Peer connection")
            return
        }

        hasReceivedSdp = true
//        var extractDesc =
        let sdp = extractDesc(desc: desc)
        //TODO
        peerConnection.setRemoteDescription(sdp, completionHandler: { [weak self](error) in
            if let error = error {
                dLog(error)
            }
//            dLog(desc)
            if desc.type == .offer,
                self?.peerConnection?.localDescription == nil {
//                self?.createAnswer()
//                guard let sdp = self?.extractDesc(desc: desc) else { return }
                self?.receivedOffer(sdp)
            }
            if desc.type == .answer {
                //  self?.peerConnection?.localDescription == nil {
                //self?.createAnswer()
                // guard let sdp = self?.extractDesc(desc: desc) else { return }
                self?.receivedAnswer(sdp)
            }
        })
    }

    func drainMessageQueue() {
        guard let peerConnection = peerConnection,
            hasReceivedSdp else {
            return
        }

        dLog("Drain Messages")

        for candidate in candidateQueue {
            dLog("Add Candidate: \(candidate)")
            peerConnection.add(candidate)
        }

        candidateQueue.removeAll()
    }
}

// string to sdp convert
extension WebRTCClient {
    func stringToSdp(from jsonString: String, sdpType: RTCSdpType) -> RTCSessionDescription {
        var extractString = jsonString.replacingOccurrences(of: "\n", with: "")
        extractString = jsonString.replacingOccurrences(of: "\r", with: "")
        extractString = jsonString.replacingOccurrences(of: "\\", with: "")
        dLog(extractString)
        let rtcSessionDescription = RTCSessionDescription(type: sdpType, sdp: extractString)
        return rtcSessionDescription
    }

    func extractDesc(desc: RTCSessionDescription) -> RTCSessionDescription {
        var extractTarget = desc
        var extractTargetSdpString = desc.sdp
//        extractTargetSdpString = extractTargetSdpString.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\\", with: "")
        return RTCSessionDescription(type: desc.type, sdp: extractTargetSdpString)
    }
}


extension WebRTCClient: RTCPeerConnectionDelegate {

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        dLog("")
    }
}

extension WebRTCClient {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        guard let peerConnection = peerConnection else {
            dLog("Check Peer connection")
            return
        }
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }

    func unmuteAudio() {
        self.setAudioEnabled(true)
    }

    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }

    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }


}

