//
//  HomeView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/09.
//

import SwiftUI

struct HomeView: View {
    @State private var rightLayoutVisible: Bool = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // 좌측 내용
                    VStack {
                        Image(systemName: "person.circle")
                            .font(.system(size: 50))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                            .padding(.leading, 100)
                            .onTapGesture {
                                rightLayoutVisible.toggle()
                            }
                        
                        // 가로로 지나는 선
                        Divider()
                            .background(Color.gray)
                            .frame(height: 1)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    if rightLayoutVisible {
                        Divider().background(Color.gray)
                        
                        // 오른쪽 내용
                        VStack {
                            HStack {
                                Text("그룹이름")
                                    .frame(maxWidth: .infinity)
                                    .padding(.top)
                                    .padding(.leading, -10)
                                    .font(.system(size: 20))
                                Image(systemName: "plus")
                                    .padding(.top)
                                    .padding(.leading, -50)
                            }
                            
                            Divider()
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
