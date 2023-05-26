//
//  VoiceChannelView.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/19.
//

import Foundation
import SwiftUI
import Alamofire
import Combine

struct VoiceChannel: Identifiable, Decodable {
    var id = UUID()
    var groupId: Int
    var channelName: String
    var channelId: Int
    var users: [String]
//    var isEnabled: Bool
    enum CodingKeys: String, CodingKey {
        case groupId
        case channelName
        case channelId
        case users
    }
}




//Button(action: {self.viewModel.startVoiceChat()}) { Text("StartVoiceChat")}

struct VoiceChannelView: View {
    @Binding var groupId: Int
    @Binding var userId: Int?
    @Binding var userName: String?
    @ObservedObject var viewModel: AudioCallViewModel

    @State var voiceChannels: [VoiceChannel] = []
    var body: some View {
        List {
            ForEach(voiceChannels, id: \.channelId) { channel in
                Section(header: Text("\(channel.channelName)").font(.title2)) {
//                    VStack() { Text("hi") } // user list 들어갈 위치
                    ForEach(channel.users, id: \.self) { user in
                        VStack() { Text(user) }
                            .swipeActions {
                            if user == userName {
                                Button(role: .destructive) {
                                    self.viewModel.disconnect()
                                    leaveChannel(userId: userId, channelId: channel.channelId)
                                } label: {
                                    Label("나가기", systemImage: "phone.down.fill")
                                }
                            }
                        }
                    }
                }
                    .onTapGesture {
                    self.viewModel.disconnect()
                    self.viewModel.connectRoom(roomID: String(channel.channelId))
                    enterChannel(userId: userId, channelId: channel.channelId)
                    getChannels(completion: { (channels) in
                        self.voiceChannels = channels
                    }, groupId)
                }
            }
        }.listStyle(InsetGroupedListStyle())
            .onChange(of: groupId) { newGroupId in
            getChannels(completion: { (channels) in
                self.voiceChannels = channels
            }, newGroupId)
        }
    }
}

func getChannels(completion: @escaping ([VoiceChannel]) -> (), _ groupId: Int) {
    let param = ["groupId": groupId]
    AF.request(APIContants.channelURL, method: .get, parameters: param, encoding: URLEncoding.default).validate(statusCode: 200..<300).responseDecodable(of: [VoiceChannel].self) { (response) in
        switch response.result {
        case .success(let channels):
            dLog(channels)
            completion(channels)
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}

func enterChannel(userId: Int?, channelId: Int) {
    let param = ["userId": userId, "channelId": channelId]
    AF.request(APIContants.enterChannelURL, method: .post, parameters: param, encoding: URLEncoding.default).responseData(completionHandler: { response in
        switch response.result {
        case .success(let res):
            dLog(res)
        case .failure(let err):
            dLog(err)
        }
    })
}

func leaveChannel(userId: Int?, channelId: Int) {
    let param = ["userId": userId, "channelId": channelId]
    AF.request(APIContants.leaveChannelURL, method: .delete, parameters: param, encoding: URLEncoding.default).responseData(completionHandler: { response in
        switch response.result {
        case .success(let res):
            dLog(res)
        case .failure(let err):
            dLog(err)
        }
    })
}

func getChannelUsers(_ channelId: Int, completion: @escaping ([String]?) -> Void) {
    AF.request("\(APIContants.channelURL)/\(channelId)/users", method: .get).responseData { reponse in
        switch reponse.result {
        case .success(let value):
            if let userNameArray = try? JSONDecoder().decode([String].self, from: value) {
                completion(userNameArray)
            } else {
                completion(nil)
            }
        case .failure(let error):
            print(error)
            completion(nil)
        }

    }
}

