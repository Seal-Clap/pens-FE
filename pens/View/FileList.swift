//
//  FileList.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import SwiftUI

struct FileList: View {
    var body: some View {
         ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)
            
            VStack {
                Text("유저 목록")
                    .font(.title)
                List {
                    ForEach(users, id: \.userEmail) { user in
                        VStack(alignment: .leading) {
                            Text("\(user.userName)").font(.title2)
                        }.padding(.leading)
                    }
                }
                .onAppear {
                    print("getusers(\(groupId))")
                    getUsers(completion: { (fetchedUsers) in
                        self.users = fetchedUsers.sorted { $0.userName < $1.userName }
                    }, groupId)
                }.listStyle(SidebarListStyle())
                //.padding()
                Button(action: {
                    isPresented = false
                }) {
                    Text("취소")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .frame(width: 300, height: 600)
    }
}

struct FileList_Previews: PreviewProvider {
    static var previews: some View {
        FileList()
    }
}
