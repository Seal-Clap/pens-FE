//
//  VoiceChannelView.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/19.
//

import Foundation
import SwiftUI

struct VoiceChannel: Identifiable {
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
