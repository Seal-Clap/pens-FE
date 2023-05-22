//
//  FileView.swift
//  pens
//
//  Created by 박상준 on 2023/05/15.
//

import SwiftUI
import Alamofire
import Combine

class FileViewModel: ObservableObject {
    @Published var downloadedFileURL: URL?
}

struct FileView: View {
    @State private var isImporting: Bool = false
    @State private var fileURL: URL?
    @Binding var selectedGroup: GroupElement //userId위해
    //
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    @State private var newDrawName: String = ""
    @State private var showingPrompt = false
    @Binding var draws: [Draw]
    @Binding var isPresented: Bool
    
    @ObservedObject var viewModel: AudioCallViewModel
    //
    @State private var showDownloadAlert = false
    //
    @ObservedObject var fileViewModel = FileViewModel()
    @State private var groups = [GroupElement]()
    //
    @State var files: [FileList] = []
    @State private var selectedFile: FileList?
    @State private var isShowingPdf = false

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
                            uploadFile(groupId: selectedGroup.groupId, fileUrl: fileURL!)
                            //uploadFile(groupId: groupId, fileUrl: fileURL!)
                        } catch {
                            // Handle error
                        }
                    }
            }
            .padding()
            //걍 파일 목록 보여주기
            ScrollView{
                LazyVGrid(columns: columns){
                    ForEach(files) { file in
                        VStack{
                            Image(systemName: "doc.plaintext").font(.system(size: 100))
                            HStack{
                                Text("\(file.fileId)")
                                Text("\(file.fileName)")
                            }
                        }.onTapGesture {
                            self.selectedFile = file
                            downloadFile(n: file.fileId, fileName: file.fileName) { url in
                                fileViewModel.downloadedFileURL = url
                                self.isShowingPdf = true
                            }
                        }
                        .fullScreenCover(isPresented: $isShowingPdf) {
                            if let url = fileViewModel.downloadedFileURL {
                                PDF_FileView(url: url)
                            }
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
        //단순 목록 보여주기
        .onAppear {
            showFileList(completion: { fileList in
                self.files = fileList
            }, selectedGroup.groupId)
        }.onChange(of: selectedGroup) { newGroup in
            showFileList(completion: { fileList in
                self.files = fileList
            }, selectedGroup.groupId)
        }
    }
    //
}

//struct FileView_Previews: PreviewProvider {
//    struct PreviewWrapper: View {
//        @State private var groupId: Int = 0
//        var body: some View {
//            FileView(groupId: $groupId, draws: .constant([]) , isPresented : .constant(false), viewModel: AudioCallViewModel())
//        }
//    }
//    static var previews: some View {
//        PreviewWrapper()
//    }
//}

