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
    var name: String
    var channelId: Int
    var isEnabled: Bool
}

struct VoiceChannelView: View {
    @Binding var groupId: Int
    var body: some View {
        VStack {
            
        }
    }
}

func getChannels(completion: @escaping ([VoiceChannel]) -> (), _ groupId: Int) {
    let param = ["groupId": groupId]
    AF.request(APIContants.channelListURL, method: .get, parameters: param, encoding: URLEncoding.default).validate(statusCode: 200..<300).responseDecodable(of: [VoiceChannel].self) { (response) in
        guard let channels = response.value else {return}
        completion(channels)
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
