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

class VoiceChannelModel: ObservableObject {
    @Published var voiceChannels: [VoiceChannel] = []
}

struct VoiceChannelView: View {
    @Binding var selectedGroup: GroupElement
    @Binding var userId: Int?
    @Binding var userName: String?
    @Binding var showMenu: Bool
    @ObservedObject var viewModel: AudioCallViewModel
    
    @ObservedObject var voiceChannelModel: VoiceChannelModel
    
    var body: some View {
        HStack {
            HStack {
                Text(selectedGroup.groupName)
                    .font(.title2)
                    .fontWeight(.regular)
                
                Button(action: {
                    showMenu = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 25, weight: .thin))
                        .foregroundColor(Color.cyan)
                }.padding(.leading, 10)
            }
            .frame(maxWidth: .infinity)
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 20, weight: .thin))
                .foregroundColor(.gray)
                .padding(.trailing)
                .onTapGesture {
                    getChannels(completion: { (channels) in
                        self.voiceChannelModel.voiceChannels = channels
                    }, selectedGroup.groupId)
                }
        }
            List {
                ForEach(voiceChannelModel.voiceChannels, id: \.channelId) { channel in
                    Section(header:
                                HStack {
//                        if(channel.users.isEmpty) {
//                            Image("voiceOFF").resizable().scaledToFit().frame(width:30, height:30)
//                        } else { Image("voiceON").resizable().scaledToFit().frame(width:30, height:30) }
                        //Text("\(channel.channelName)").font(.title2)
                        if(channel.users.contains(userName ?? "")) {
                            Image(systemName: "speaker.wave.2.fill").font(.system(size: 20, weight: .light)).foregroundColor(.black)
                            Text("\(channel.channelName)").font(.system(size: 22, weight: .light)).foregroundColor(.black).padding(.leading)
                        } else {
                            Image(systemName: "speaker.slash.fill").font(.system(size: 20, weight: .light))
                            Text("\(channel.channelName)").font(.system(size: 22, weight: .thin)).padding(.leading)
                        }
                    })
                        {
                        ForEach(channel.users, id: \.self) { user in
                            VStack() { Text(user) }
                                .swipeActions {
                                    if user == userName {
                                        Button(role: .destructive) {
                                            self.viewModel.disconnect()
                                            leaveChannel(userId: userId, channelId: channel.channelId) {
                                                getChannels(completion: { (channels) in
                                                    self.voiceChannelModel.voiceChannels = channels
                                                }, selectedGroup.groupId)
                                            }
                                        } label: {
                                            Label("나가기", systemImage: "phone.down.fill")
                                        }
                                    }
                                }
                        }
                    }
                    .onTapGesture {
                        //                    leaveChannel(userId: userId, channelId: channel.channelId)
                        // 전에 들어간 채널..? 나가기..?
                        for channel in voiceChannelModel.voiceChannels {
                            if (channel.users.contains(userName ?? "")) {
                                return
                            }
                        }


                        self.viewModel.disconnect()

                        if(channel.users.contains(userName ?? "")) {
                            leaveChannel(userId: userId, channelId: channel.channelId) {
                                getChannels(completion: { (channels) in
                                    self.voiceChannelModel.voiceChannels = channels
                                }, selectedGroup.groupId)
                            }
                        }
                        else {
                            self.viewModel.connectRoom(roomID: String(channel.channelId))
                            enterChannel(userId: userId, channelId: channel.channelId) {
                                getChannels(completion: { (channels) in
                                    self.voiceChannelModel.voiceChannels = channels
                                }, selectedGroup.groupId)
                            }
                        }
                    }
                }
            }.listStyle(InsetGroupedListStyle())
            .onChange(of: selectedGroup.groupId) { newGroupId in
                    getChannels(completion: { (channels) in
                        self.voiceChannelModel.voiceChannels = channels
                    }, newGroupId)
                }
            .onChange(of: viewModel.signalReceived) { flag in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    getChannels(completion: { (channels) in
                        self.voiceChannelModel.voiceChannels = channels
                    }, selectedGroup.groupId)
                }
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

func enterChannel(userId: Int?, channelId: Int, completion: @escaping () -> Void) {
    let param = ["userId": userId, "channelId": channelId]
    AF.request(APIContants.enterChannelURL, method: .post, parameters: param, encoding: URLEncoding.default).responseData(completionHandler: { response in
        switch response.result {
        case .success(let res):
            dLog(res)
            completion()
        case .failure(let err):
            dLog(err)
        }
    })
}

func leaveChannel(userId: Int?, channelId: Int, completion: @escaping () -> Void) {
    let param = ["userId": userId, "channelId": channelId]
    AF.request(APIContants.leaveChannelURL, method: .delete, parameters: param, encoding: URLEncoding.default).responseData(completionHandler: { response in
        switch response.result {
        case .success(let res):
            dLog(res)
            completion()
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

