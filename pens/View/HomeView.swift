//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI

struct HomeView: View {
    //로그아웃 위해
    @Binding var loginState: Bool?
    @State private var showingLogoutAlert = false
    //그룹
    @StateObject var leaveGroup = LeaveGroup()
    @State private var showInviteGroupMember = false
    @State private var showAddGroup = false
    @State private var grouplist: [String] = []
    //
    @State private var selectedGroupName: String = "not selected"
    //
    @State private var userId: Int? = nil


    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("그룹 목록").font(.title)
                }
                Divider()
                List {
                        ForEach(grouplist, id: \.self) { group in
                            Text(group).font(.title2).onTapGesture {
                                selectedGroupName = group
                            }
                    }
                    .onDelete(perform: deleteGroup)
                }
                .listStyle(SidebarListStyle())
                Button(action: {
                    showAddGroup = true
                }, label: { Text("그룹 추가").font(.title2) })
            }
            VStack {
                Text("User ID: \(userId ?? 0)")
                    .onAppear {
                    userId = getUserId()
                }
                Text(selectedGroupName)
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
                Divider()
                List{
                    VStack{
                        Text("그룹_멤버").font(.title)
                        
                    }
                }
                Divider()
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("로그아웃")
                        .font(.title3)
                        .padding()
                        .foregroundColor(.blue)
                        .frame(height: 25)
                }.alert(isPresented: $showingLogoutAlert) {
                    Alert(
                        title: Text("로그아웃 확인"),
                        message: Text("로그아웃 하시겠습니까?"),
                        primaryButton: .destructive(Text("로그아웃")) {
                            deleteToken()
                            loginState = false
                        },
                        secondaryButton: .cancel()
                    )
                }
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
    @State static private var loginState: Bool? = true
    static var previews: some View {
        HomeView(loginState: $loginState).environmentObject(LeaveGroup())
    }
}
