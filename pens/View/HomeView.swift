//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI
import Alamofire

struct HomeView: View {
    //로그아웃 위해
    @Binding var loginState: Bool?
    @State private var showingLogoutAlert = false
    //그룹
    @State private var grouplist: [String] = []
    @State private var showInviteGroupMember = false
    @State private var showAddGroup = false
    private let groupLoade = GroupLoader()
    //
    @State private var selectedGroup: GroupElement = GroupElement(groupId: 0, groupName: "local")
    @State private var showingGroupLeaveAlert = false
    //
    @State private var userId: Int? = nil
    @State private var groups = [GroupElement]()
    //
    @State private var isImporting: Bool = false
    @State private var fileURL: URL?
    
    @ObservedObject var viewModel: AudioCallViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("그룹 목록").font(.title)
                List {
                    ForEach(groups, id: \.groupId) { group in
                        // Text("Group ID: \(group.groupId)")
                        VStack(alignment: .leading) {
                            Text("\(group.groupName)").font(.title2)
                        }
                        .padding(.leading)
                            .onTapGesture {
                            selectedGroup = group

                        }.swipeActions {
                            Button(role: .destructive) {
                                delete(group, groups, userId!)
                            } label: {
                                Label("나가기", systemImage: "trash")
                            }
                        }
                    }
                }.onAppear {
                    print("get Group \(groups)")
                    getGroups(completion: { (groups) in
                        self.groups = groups
                    }, userId)
                    groups.sort { $0.groupId > $1.groupId }
                }.listStyle(SidebarListStyle())


                    .onAppear {
                    print("get Group \(groups)")
                    getGroups(completion: { (groups) in
                        self.groups = groups
                    }, userId)
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
                Text(selectedGroup.groupName)
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
                    .sheet(isPresented: $showInviteGroupMember) {
                    InviteGroupMemberView(isPresented: $showInviteGroupMember, groupId: selectedGroup.groupId)
                }
                    .padding()
                Divider()
                List {
                    VStack {
                        Text("그룹_멤버").font(.title)
                    }
                }
                Divider()
                Button(action: {
                    //그룹 사용자 보여주기 동작 추가
                }) {
                    Text("그룹 멤버 보기")
                        .font(.title3)
                        .padding()
                        .foregroundColor(.white)
                        .frame(height: 25)
                }.background(RoundedRectangle(cornerRadius: 6).fill(Color.black))
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
            LazyVGrid(columns: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Columns@*/[GridItem(.fixed(200))]/*@END_MENU_TOKEN@*/) {
                Button(action: { // file upload button
                    isImporting = true
                }) {
                    Image(systemName: "plus.rectangle")
                        .resizable()
                        .frame(width: 60, height: 45, alignment: .center)
                }.fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.pdf, .presentation, .image],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedFiles = try result.get()
                        fileURL = selectedFiles.first
                        uploadFile(groupId: selectedGroup.groupId, fileUrl: fileURL!)
                    } catch {
                        // Handle error
                    }
                }
                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                Button(action: {self.viewModel.connectRoom(roomID: "1")}) { Text("Connect")}
                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                Button(action: {self.viewModel.startVoiceChat()}) { Text("StartVoiceChat")}
            }
        }.overlay(
            Group {
                if showInviteGroupMember {
                    InviteGroupMemberView(isPresented: $showInviteGroupMember, groupId: selectedGroup.groupId)
                }
                if showAddGroup {
                    AddGroupView(isPresented: $showAddGroup, onAddGroup: { groupID in
                        getGroups(completion: { (groups) in
                            self.groups = groups
                        }, userId)
                        groups.sort { $0.groupId > $1.groupId }
                    })
                    
                }
            }
        )
    }
    func uploadFile(groupId: Int, fileUrl: URL) {
        let url = URL(string: "\(APIContants.fileUploadURL)?groupId=\(groupId)")!

        // Start accessing a security-scoped resource.
        guard fileUrl.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            return
        }

        // Make sure you release the security-scoped resource when you finish.
        defer { fileUrl.stopAccessingSecurityScopedResource() }

        do {
            let fileData = try Data(contentsOf: fileUrl)
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(fileData, withName: "file", fileName: fileUrl.lastPathComponent)
            }, to: url, method: .post).validate(statusCode: 200..<300)
            .response { response in
                debugPrint(response)
            }
        } catch {
            print("Unable to load data: \(error)")
        }
    }


}


struct HomeView_Previews: PreviewProvider {
    @State static private var loginState: Bool? = true
    static var previews: some View {
        HomeView(loginState: $loginState, viewModel: AudioCallViewModel()).environmentObject(LeaveGroup())
    }
}

