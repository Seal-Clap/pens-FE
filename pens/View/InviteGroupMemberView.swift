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
    var groupId: Int
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
                HStack{
                    Button(action: {
                        getGroupId(userId: userId, groupId: groupId) { result in
                            switch result {
                            case .success(let groupId):
                                inviteGroup(groupId: groupId, userEmail: emailAddress) { result in
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
                        Text("초대")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("취소")
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

struct InviteGroupMemberView_Previews: PreviewProvider {
    static var previews: some View {
        InviteGroupMemberView(isPresented: .constant(false), groupId: 0)
    }
}
