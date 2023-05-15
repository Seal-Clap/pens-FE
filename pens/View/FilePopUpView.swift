//
//  FilePopUpView.swift
//  pens
//
//  Created by 박상준 on 2023/05/13.
//

import SwiftUI

struct FilePopUpView: View {
    @Binding var isPresented: Bool
    @Binding var folders: [Folder]
    //
    @State private var newFolderName: String = ""
    @State private var showingPrompt = false

    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)
            VStack{
                Button(action: {
                    // 파일 추가 동작
                }){
                    HStack{
                        Image(systemName: "doc.badge.arrow.up").padding(.leading)
                        Text("새 문서").font(.title3).padding()
                        
                    }.background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    FolderName.setFolderName(folders: $folders, isPresented: $isPresented)
                }){
                    HStack{
                        Image(systemName: "folder").padding(.leading)
                        Text("새 폴더").font(.title3).padding()
                    }.background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    isPresented = false
                }) {
                    Text("닫기")
                        .padding()
                }
            }.padding()
        } .frame(width: 200, height: 150)
    }
}

struct FilePopUpView_Previews: PreviewProvider {
    static var previews: some View {
        FilePopUpView(isPresented: .constant(false), folders: .constant([]))
    }
}
