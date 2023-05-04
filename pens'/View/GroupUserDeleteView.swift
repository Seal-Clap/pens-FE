//
//  GroupUserDeleteView.swift
//  pens'
//
//  Created by 신지선 on 2023/05/02.
//

import SwiftUI

struct GroupDeleteUserView: View {
    @Binding var isPresented: Bool
    var userId: String
    var groupId: String

    @StateObject private var leaveGroup = LeaveGroup()

    var body: some View {
        VStack {
            Text("그룹에서 나가시겠습니까?")
                .font(.title)
                .padding()
            HStack {
                Button(action: {
                    leaveGroup.leaveGroup(groupId: Int(groupId)!, userId: Int(userId)!) { result in
                        switch result {
                        case .success:
                            isPresented = false
                        case .failure(let error):
                            print("Failed to delete user from group: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("예")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                }
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                .padding()

                Button(action: {
                    isPresented = false
                }) {
                    Text("아니오")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 40)
                }
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding()
    }
}

struct GroupDeleteUserView_Previews: PreviewProvider {
    static var previews: some View {
        GroupDeleteUserView(isPresented: .constant(true), userId: "sampleUserId", groupId: "sampleGroupId")
    }
}
