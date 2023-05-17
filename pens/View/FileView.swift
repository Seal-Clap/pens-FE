//
//  FileView.swift
//  pens
//
//  Created by 박상준 on 2023/05/15.
//

import SwiftUI
import Alamofire

struct FileView: View {
    @State private var isImporting: Bool = false
    @State private var fileURL: URL?
    @Binding var groupId : Int
    //
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    @State private var newDrawName: String = ""
    @State private var showingPrompt = false
    @Binding var draws: [Draw]
    @Binding var isPresented: Bool
    
    @ObservedObject var viewModel: AudioCallViewModel
    //
    @State private var fileId = ""
    @State private var showDownloadAlert = false
    @State private var fileURLs: [URL] = []
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                //새노트
                Button(action : {
                    DrawFileName.setDrawFileName(draws: $draws, isPresented: $isPresented)
                }){
                    VStack{
                        Image(systemName: "note.text").font(.system(size: 30))
                        Text("새 노트")
                    }.foregroundColor(.black)
                }
                //파일 업로드
                Button(action: { // file upload button
                    isImporting = true
                }) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 30))
                }.foregroundColor(.black)
                    .padding()
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.pdf, .presentation, .image],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let selectedFiles = try result.get()
                        fileURL = selectedFiles.first
                        uploadFile(groupId: groupId, fileUrl: fileURL!)
                    } catch {
                        // Handle error
                    }
                }
            //download
                Button(action : {
                    FileDownloadView.getFileId { fileId in
                        downloadFile(n: fileId) { url in
                            self.fileURLs.append(url)
                        }
                    }

                }){
                    VStack{
                        Image(systemName: "arrow.down.doc").font(.system(size: 30))
                    }.foregroundColor(.black)
                }
            }.padding()
            //파일 목록
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(fileURLs, id: \.self) { url in
                        NavigationLink(destination: PDF_FileView(url: url)) {
                            VStack {
                                Image(systemName: "doc.plaintext").font(.system(size: 100))
                                Text(url.lastPathComponent)
                            }.foregroundColor(.black)
                        }
                    }
                }
            }
            //빈 노트
            ScrollView{
                LazyVGrid(columns: columns) {
                    ForEach(draws) { draw in
                        NavigationLink(destination: DrawView(drawID: draw.id, drawName : draw.drawFileName)) {
                            VStack {
                                Image(systemName: "doc.richtext").font(.system(size: 100))
                                Text(draw.drawFileName)
                            }.foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }
    //
}

struct FileView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var groupId: Int = 0
        var body: some View {
            FileView(groupId: $groupId, draws: .constant([]) , isPresented : .constant(false), viewModel: AudioCallViewModel())
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}


