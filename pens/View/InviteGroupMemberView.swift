//
//  InviteGroupMemberView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/16.
//

import SwiftUI

struct InviteGroupMemberView: View {
    @Binding var isPresented: Bool
    @State private var emailAddress: String = ""
    @State private var userId: Int = (getUserId() ?? 0)
    var groupName: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)

            VStack {
                Text("이메일로 사용자 초대")
                    .font(.title)
                    .padding()

                TextField("이메일 주소 입력", text: $emailAddress)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    // 초대 동작 추가
                    print("InviteGroupMemberView++++++++userId : \(userId) +++++++++++")
                    getGroupId(userId: userId, groupName: groupName) { result in
                        print("InviteGroupMemberView+++++++++++result : \(result)+++++++++++++")
                        switch result {
                        case .success(let groupId):
                            print("InviteGroupMemberView++++++++++++++groupId : \(groupId) +++++++++++++")
                            let userEmail = emailAddress
                            inviteGroup(groupId: groupId, userEmail: userEmail) { result in
                                switch result {
                                case .success(let responseString):
                                    print("Successfully sent data: \(responseString)")
                                case .failure(let error):
                                    print("Error sending data: \(error.localizedDescription)")
                                }
                            }
                        case .failure(let error):
                            print("Error getting groupId: \(error.localizedDescription)")
                        }
                    }
                    print("이메일 주소: \(emailAddress)")
                    isPresented = false
                }) {
                    Text("초대 보내기")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }.padding()

                Button(action: {
                    isPresented = false
                }) {
                    Text("취소")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }.frame(width: 300, height: 250)
    }
}

struct InviteGroupMemberView_Previews: PreviewProvider {
    static var previews: some View {
        InviteGroupMemberView(isPresented: .constant(false), groupName: "sampleName")
    }
}
