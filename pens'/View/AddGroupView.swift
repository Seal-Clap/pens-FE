//
//  AddGroupView.swift
//  pens'
//
//  Created by 박상준 on 2023/04/16.
//

import SwiftUI

struct AddGroupView: View {
    @Binding var isPresented: Bool
    @State private var groupName: String = ""
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)

            VStack {
                Text("그룹 추가하기")
                    .font(.title)
                    .padding()

                TextField("그룹 이름 입력", text: $groupName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    // 그룹추가 동작
                    print("이메일 주소: \(groupName)")
                    isPresented = false
                }) {
                    Text("그룹 추가")
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }.padding()

                Button(action: {
                    isPresented = false
                }) {
                    Text("취소")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 250)
    }
}

struct AddGroupView_Previews: PreviewProvider {
    static var previews: some View {
        AddGroupView(isPresented: .constant(false))
    }
}
