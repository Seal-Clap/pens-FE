//
//  GroupUsersView.swift
//  pens
//
//  Created by 최진현 on 2023/05/11.
//

import SwiftUI

struct GroupUsersView: View {
    @Binding var isPresented: Bool
    @State private var users = [UserElement]()
    @State var groupId: Int
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)
            
            VStack {
                Text("유저 목록")
                    .font(.title).padding()
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
                    Text("닫기")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .frame(width: 300, height: 450)
    }
    
    struct GroupUsersView_Previews: PreviewProvider {
        static var previews: some View {
            GroupUsersView(isPresented: .constant(true), groupId: 0)
        }
    }
    
}
