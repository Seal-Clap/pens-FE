//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI

struct HomeView: View {
    @StateObject var leaveGroup = LeaveGroup()
    @State private var showInviteGroupMember = false
    @State private var showAddGroup = false
    @State private var grouplist: [String] = []

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("그룹 목록").font(.title)
                }
                Divider()
                List {
                    HStack {
                        Image(systemName: "person.circle")
                            .font(.system(size: 40))
                            .padding(.leading)
                        Text("사용자").font(.title2)
                    }
                    ForEach(grouplist, id: \.self) { group in
                        Text(group).font(.title2)
                    }
                    .onDelete(perform: deleteGroup)
                }
                .listStyle(SidebarListStyle())
                Button(action: {
                    showAddGroup = true
                }, label: { Text("그룹 추가").font(.title2) })
            }
            VStack {
                Text("그룹 이름")
                    .font(.title)
                    .padding(.leading)
                Button(action: {
                    showInviteGroupMember = true
                }) {
                    Text("초대")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                }
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                .padding()
                Spacer()
            }
            Text("Detail")
        }.overlay(
            Group {
                if showInviteGroupMember {
                    InviteGroupMemberView(isPresented: $showInviteGroupMember)
                }
                if showAddGroup {
                    AddGroupView(isPresented: $showAddGroup, onAddGroup: { groupID in
                        grouplist.append(groupID)
                    })
                }
            }
        )
    }

    func deleteGroup(at offsets: IndexSet) {
        for index in offsets {
            let groupId = grouplist[index]
            if let groupIdInt = Int(groupId), let userIdInt = Int("user_id") {
                leaveGroup.leaveGroup(groupId: groupIdInt, userId: userIdInt) { result in
                    if case .success = result {
                        DispatchQueue.main.async {
                            grouplist.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(LeaveGroup())
    }
}
