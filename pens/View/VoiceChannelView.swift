//
//  VoiceChannelView.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/19.
//

import Foundation
import SwiftUI
import Alamofire

struct VoiceChannel: Identifiable, Decodable {
    var id = UUID()
    var groupId: Int
    var channelName: String
    var channelId: Int
//    var isEnabled: Bool
    enum CodingKeys: String, CodingKey {
        case groupId
        case channelName
        case channelId
    }
}

struct VoiceChannelView: View {
    @Binding var groupId: Int
    @State var voiceChannels: [VoiceChannel] = []
    var body: some View {
        List {
            Section(header: Text("음성채널").font(.title)) {
                ForEach(voiceChannels, id: \.channelId) { channel in
                    VStack(alignment: .leading) {
                        Text("\(channel.channelName)").font(.title3)
                    }
                        .padding(.leading)
                        .onTapGesture {
                        //
                    }
                }
            }
        }.listStyle(InsetGroupedListStyle())
            .onChange(of: groupId) { newGroupId in
            getChannels(completion: { (channels) in
                self.voiceChannels = channels
                self.voiceChannels.sort { $0.channelId > $1.channelId }
            }, newGroupId)
        }
    }
}

func getChannels(completion: @escaping ([VoiceChannel]) -> (), _ groupId: Int) {
    let param = ["groupId": groupId]
    AF.request(APIContants.channelListURL, method: .get, parameters: param, encoding: URLEncoding.default).validate(statusCode: 200..<300).responseDecodable(of: [VoiceChannel].self) { (response) in
        switch response.result {
        case .success(let channels):
            completion(channels)
        case .failure(let error):
            print("Error: \(error)")
        }
    }
}

struct VoiceChannleView_Previews: PreviewProvider {
    struct PriviewWrapper: View {
        @State private var groupId: Int = 0
        var body: some View {
            VoiceChannelView(groupId: $groupId)
        }
    }
    static var previews: some View {
        PriviewWrapper()
    }
}
