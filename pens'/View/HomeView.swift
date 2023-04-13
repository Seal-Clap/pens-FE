//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
            NavigationSplitView {
                VStack{
                    HStack{
                        Text("Group List").font(.title)
                        
                    }.padding(.top, -50)
                    Divider()
                    List {
                        HStack{
                            Image(systemName: "person.circle")
                                .font(.system(size: 40))
                                .padding(.leading)
                            Text("사용자").font(.title3)
                        }
                    }
                    .navigationSplitViewColumnWidth(150)
                    Button(action: {}, label: {Text("사용자 추가").font(.title2)})
                }
            }
            content: {
                HStack{
                    Text("그룹 이름")
                        .font(.title)
                        .padding(.leading, 60)
                    Spacer()
                    Button(action: {}, label: {Text("초대")})
                        .padding(.leading, -55)
                }.padding(.top, -40)
                VStack{
                    Divider()
                    Spacer()
                }.navigationSplitViewColumnWidth(250)
            }
            detail: {
                Text("Detail")
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
