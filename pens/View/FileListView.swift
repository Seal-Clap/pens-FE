//
//  FileListView.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import SwiftUI

struct FileListView: View {
    @Binding var isPresented: Bool
    @State var groupId: Int
    @State var files: [FileList] = []
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 10)
            
            VStack {
                Text("그룹\(groupId) : 파일 목록")
                    .font(.title).padding()
                List(files) { file in
                    HStack{
                        Text("\(file.fileId)")
                        Text(file.fileName)
                    }
                }
                .onAppear {
                    showFileList(completion: { fileList in
                        self.files = fileList
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
        .frame(width: 300, height: 400)
    }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView(isPresented: .constant(true), groupId: 0)
    }
}
