//
//  DocumentView.swift
//  pens
//
//  Created by 박상준 on 2023/05/12.
//

import SwiftUI

struct DocumentView: View {
    @State private var addFileView : Bool = false
    @State private var folders: [Folder] = []
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    addFileView = true
                }) {
                    Image(systemName: "doc.badge.plus").font(.system(size: 25))
                }.foregroundColor(.gray)
                .padding()
        }
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(folders) { folder in
                        Button(action: {}){
                            VStack{
                                Image(systemName: "folder").font(.system(size: 100))
                                Text(folder.folderName)
                            }.foregroundColor(.black)
                        }
                    }
                }
            }
        Spacer()
    }.overlay(
        Group {
            if addFileView {
                FilePopUpView(isPresented: $addFileView, folders: $folders)
            }
        }
    )
}
    
struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView()
        }
    }
}
