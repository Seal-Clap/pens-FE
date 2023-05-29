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
                    .font(.title3)
                    .fontWeight(.light)
                    .padding()
                List {
                    ForEach(Array(users.enumerated()), id: \.element.userEmail) { index, user in
                        VStack(alignment: .leading) {
                            HStack{
                                Image(systemName: "fish.circle")
                                    .font(.system(size: 10, weight: .ultraLight))
                                    .foregroundColor(index % 2 == 0 ? .cyan : .mint)
                                Text("\(user.userName)")
                                    .font(.system(size: 15, weight: .light))
                            }
                        }.padding(.leading)
                    }
                }
//                List {
//                    ForEach(users, id: \.userEmail) { user in
//                        VStack(alignment: .leading) {
//                            HStack{
//                                Image(systemName: "circle.fill").font(.system(size: 5, weight: .ultraLight)).foregroundColor(.cyan)
//                                Text("\(user.userName)")
//                                    .font(.system(size: 15, weight: .light))
//                            }
//                        }.padding(.leading)
//                    }
//                }
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
                        .font(.system(size: 15, weight: .light))
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
