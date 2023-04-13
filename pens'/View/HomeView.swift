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
                        
                    }
                    Divider()
                    List {
                        HStack{
                            Image(systemName: "person.circle")
                                .font(.system(size: 40))
                                .padding(.leading)
                            Text("사용자").font(.title2)
                        }
                    }
                    .navigationSplitViewColumnWidth(150)
                    Button(action: {}, label: {Text("사용자 추가").font(.title2)})
                }
            }
            content: {
                VStack{
                    Text("그룹 이름")
                        .font(.title)
                        .padding(.leading)
                    Button(action: {}) {
                            Text("초대")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                            }.background(RoundedRectangle(cornerRadius: 8).fill(Color.gray))
                            .padding()
                }
                
                Spacer()
                VStack{
                    
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
