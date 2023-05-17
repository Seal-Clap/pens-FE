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
}

class WebRTCClient: NSObject {
    var factory: RTCPeerConnectionFactory
    var remoteAudioTrack: RTCAudioTrack?
    private let mediaConstraints = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue]
    private var candidateQueue = [RTCIceCandidate]()
    private var peerConnection: RTCPeerConnection?
    var localAudioTrack: RTCAudioTrack?
    var localStream: RTCMediaStream?
    var rtcAudioSession: RTCAudioSession?
    
    
    weak var delegate: WebRTCClientDelegate?

    private var hasReceivedSdp = false

    override init() {
        let encoderFactory = RTCDefaultVideoEncoderFactory()
        let decoderFactory = RTCDefaultVideoDecoderFactory()
        self.factory = RTCPeerConnectionFactory(encoderFactory: encoderFactory, decoderFactory: decoderFactory)
        super.init()
        setup()
    }


    var AudioIsEnable: Bool {
        get {
            if(localAudioTrack == nil) {
                return true
            }

            return localAudioTrack!.isEnabled
        }
        set {
            localAudioTrack?.isEnabled = newValue;
        }
    }

    func setup() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
        let config = generateRTCConfig()

        peerConnection = self.factory.peerConnection(with: config, constraints: constraints, delegate: self)

        createMediaSenders()

    }

    func createOffer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true"],
            optionalConstraints: nil)

        self.peerConnection?.offer(for: RTCMediaConstraints(mandatoryConstraints: mediaConstraints, optionalConstraints: nil), completionHandler: { (sdp, error) in
            guard let sdp = sdp else {
                print("Failed to create offer: \(error?.localizedDescription ?? "")")
                return
            }

            let sdpDescription = RTCSessionDescription(type: .offer, sdp: sdp.sdp)
            self.setLocalSDP(sdpDescription, type: "offer")
        })
    }

    func receivedOffer(_ remoteSdp: RTCSessionDescription, roomId: String) {
        self.peerConnection?.setRemoteDescription(remoteSdp, completionHandler: { (error) in
            if let error = error {
                print("Failed to set remote description: \(error.localizedDescription)")
                return
            }

            self.createAnswer()
        })
    }

    private func createAnswer() {
        let constraints = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "true"],
            optionalConstraints: nil)

        self.peerConnection?.answer(for: constraints, completionHandler: { (sdp, error) in
            guard let sdp = sdp else {
                print("Failed to create answer: \(error?.localizedDescription ?? "")")
                return
            }
            let sdpDescription = RTCSessionDescription(type: .answer, sdp: sdp.sdp)
            self.setLocalSDP(sdpDescription, type: "answer")
        })
    }



    func disconnect() {
        hasReceivedSdp = false
        peerConnection?.close()
        peerConnection = nil
    }


    private func setLocalSDP(_ sdp: RTCSessionDescription, type: String) {
        guard let peerConnection = peerConnection else {
            dLog("Check PeerConnection")
            return
        }

        peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
            if let error = error {
                debugPrint(error)
            }
        })

        if let data = sdp.jsonData() {
            switch type {
            case "offer":
                self.delegate?.webRTCClient(self, sendData: data, type: "offer")
            case "answer":
                self.delegate?.webRTCClient(self, sendData: data, type: "answer")
            default:
                dLog("type not defined")
            }
//            self.delegate?.webRTCClient(self, sendData: data)
            //                    WebSocketClient().send(data: jsonData)
            dLog("Send Local SDP")
        }
    }
}

// MARK: Preparing parts.
extension WebRTCClient {
    private func generateRTCConfig() -> RTCConfiguration {
        let config = RTCConfiguration()
        let pcert = RTCCertificate.generate(withParams: ["expires": NSNumber(value: 100000),
            "name": "RSASSA-PKCS1-v1_5"
            ])
        config.iceServers = [RTCIceServer(urlStrings: Config.default.webRTCIceServers)]
        config.sdpSemantics = RTCSdpSemantics.unifiedPlan
        config.certificate = pcert

        return config
    }

    private func createMediaSenders() {
        guard let peerConnection = peerConnection else {
            dLog("Check PeerConnection")
            return
        }
        localStream = factory.mediaStream(withStreamId: "media")
        let constraints = RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: nil)
        let audioSource = self.factory.audioSource(with: constraints)
        localAudioTrack = self.factory.audioTrack(with: audioSource, trackId: "audio")
        let mediaTrackStreamIDs = ["ARDAMS"]
    
        peerConnection.add(localAudioTrack!, streamIds: mediaTrackStreamIDs)
        
        rtcAudioSession = RTCAudioSession.sharedInstance()
        rtcAudioSession?.lockForConfiguration()
        do {
            try rtcAudioSession?.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try rtcAudioSession?.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            dLog(error)
        }
        rtcAudioSession?.unlockForConfiguration()
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

        //TODO
        peerConnection.setRemoteDescription(desc, completionHandler: { [weak self](error) in
            if let error = error {
                dLog(error)
            }

            if desc.type == .offer,
                self?.peerConnection?.localDescription == nil {
                self?.createAnswer()
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

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        dLog("\(stateChanged.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        dLog("")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        dLog("")
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        dLog("")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        dLog("\(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        dLog("")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        //TODO
        guard let message = candidate.jsonData() else { return }
        delegate?.webRTCClient(self, sendData: message, type: "ice")
        dLog("")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        dLog("")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        dLog("")
    }
}

