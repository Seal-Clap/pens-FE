//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI
import Alamofire
import Combine

struct HomeView: View {
    //로그아웃 위해
    @Binding var loginState: Bool?
    @State private var showingLogoutAlert = false
    //그룹
    @State private var grouplist: [String] = []
    @State private var showInviteGroupMember = false
    @State private var showAddGroup = false
    @State private var showGroupUsers = false
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
    @State private var addFileView : Bool = false
    @State private var draws: [Draw] = []
    //
    @State private var showFileList = false
    
    var body: some View {
        NavigationView {
            //그룹 목록부분
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
                    // duplicated request TODO
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
            //음셩채팅부분
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
                .padding()
                Divider()
                List {
                        Button(action: {
                            let destination: DownloadRequest.Destination = { _, _ in
                                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                let fileURL = documentsURL.appendingPathComponent("testfile.pdf")
                                
                                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                            }
                            AF.download(
                                APIContants.baseURL+"/file/download?groupId=1000&fileName=testfile.pdf",
                                to: destination)
                            .downloadProgress { progress in
                                print("Download Progress: \(progress.fractionCompleted)")
                            }
                            .response { response in
                                if response.error == nil, let filePath = response.fileURL?.path {
                                    print("File downloaded successfully: \(filePath)")
                                }
                            }
                        }) {Text("Test file download")}
                    
                        Button(action: {
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileURL = documentsURL.appendingPathComponent("testfile.pdf")
                            do {
                                let fileData = try Data(contentsOf: fileURL)
                                print("file data is empty: \(fileData.isEmpty), \(fileData.description)")
                                // file data 접근 하는 부분
                            } catch {
                                print("Error loading data: \(error)")
                            }
                        }) {Text("access testfile.pdf")}
                        //
                        Button(action: {self.viewModel.connectRoom(roomID: "1")}) { Text("Connect")}
                        Button(action: {self.viewModel.startVoiceChat()}) { Text("StartVoiceChat")}

                }.listStyle(InsetGroupedListStyle())
                VoiceChannelView(groupId: $selectedGroup.groupId, viewModel: viewModel)
                Divider()
                //파일 목록 보기
                Button(action: {
                    showFileList = true
                }){
                    Text("그룹 파일 목록").font(.title3)
                        .padding()
                        .foregroundColor(.white)
                        .frame(height: 25)
                }.background(RoundedRectangle(cornerRadius: 6).fill(Color.black))
                //그룹 목록 보기
                Button(action: {
                    showGroupUsers = true
                }) {
                    Text("그룹 멤버 보기")
                        .font(.title3)
                        .padding()
                        .foregroundColor(.white)
                        .frame(height: 25)
                }.background(RoundedRectangle(cornerRadius: 6).fill(Color.black))
                //로그아웃
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
            VStack{
                FileView(groupId : $selectedGroup.groupId,draws : $draws, isPresented: $addFileView,viewModel: AudioCallViewModel())
            }.navigationTitle("문서")
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
                if showGroupUsers {
                    GroupUsersView(isPresented: $showGroupUsers, groupId: selectedGroup.groupId)
                }
                if showFileList {
                    FileListView(isPresented: $showFileList, groupId: selectedGroup.groupId)
                }
            }
        )
    }
}


struct HomeView_Previews: PreviewProvider {
    @State static private var loginState: Bool? = true
    static var previews: some View {
        HomeView(loginState: $loginState, viewModel: AudioCallViewModel()).environmentObject(LeaveGroup())
    }
}

