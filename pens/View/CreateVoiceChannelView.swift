//
//  CreateVoiceChannelView.swift
//  pens
//
//  Created by 박상준 on 2023/05/30.
//

import SwiftUI

struct CreateVoiceChannelView: View {
    
    @ObservedObject var voiceChannelModel: VoiceChannelModel
    
    @Binding var isPresented: Bool
    var groupId : Int
    @State private var channelName: String = ""
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)

            VStack {
                Text("음성채널 생성")
                    .font(.title3)
                    .fontWeight(.light)
                    .padding()

                TextField("채널 이름을 입력해주세요.", text: $channelName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack{
                    //생성버튼
                    Button(action: {
                        //추가 동작
                        createNewChannel(groupId: groupId, channelName: channelName){
                            DispatchQueue.main.async {
                                self.isPresented = false
                            }
                            getChannels(completion: { (channels) in
                                voiceChannelModel.voiceChannels = channels
                            }, groupId)
                        }
                    }) {
                        Text("생성")
                            .font(.system(size: 15, weight: .light))
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    //취소 버튼
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("취소")
                            .font(.system(size: 15, weight: .light))
                            .padding()
                            .background(Color.cyan)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }.frame(width: 300, height: 250)
    }
}

//struct CreateVoiceChannelView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateVoiceChannelView(voiceChannelModel: VoiceChannelModel(), isPresented: .constant(false), groupId: 0)
//    }
//}
