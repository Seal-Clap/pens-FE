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
                        Text("그룹 이름")
                            .font(.title)
                            .navigationSplitViewColumnWidth(400)
                            .padding(.leading, 100)
                        Spacer()
                        Button(action: {}, label: {Text("초대")}).padding(.leading, -60)
                    }
                    
                    Divider()
                    Spacer()
                }
            }
            content: {
                HStack{
                    Text("그룹 추가").font(.title2)
                    Image(systemName: "plus")
                        .font(.system(size: 25))
                }
                Divider()
                List {
                    HStack{
                        Image(systemName: "person.circle")
                            .font(.system(size: 40))
                            .padding(.leading, -5)
                        Text("사용자").font(.title3)
                    }
                }
                .navigationSplitViewColumnWidth(150)
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
