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
    @Published var fileId: Int?
    @Published var fileName: String?
}

struct FileView: View {
    @State private var isImporting: Bool = false
    @State private var fileURL: URL?
    @Binding var selectedGroup: GroupElement //userId위해
    //
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 5)
    @State private var newDrawName: String = ""
    @State private var showingPrompt = false
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
    @State private var isShowingDraw = false
    
    @State private var showingDeleteAlert = false
    @Binding var userId: Int?

    var body: some View {
        VStack{
            HStack{
                Spacer()
                //새노트
                Button(action : {
                    DrawFileName.setDrawFileName(isPresented: $isPresented, groupId: selectedGroup.groupId) {
                        showFileList(completion: { fileList in
                            self.files = fileList
                        }, selectedGroup.groupId)
                    }
                }){
                    VStack{
                        Image(systemName: "pencil.tip.crop.circle.badge.plus").font(.system(size: 25, weight: .ultraLight))
                    }
                }
                //파일 업로드
                Button(action: { // file upload button
                    isImporting = true
                }) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 25, weight: .ultraLight))
                }
                    .padding()
                    .fileImporter(
                        isPresented: $isImporting,
                        allowedContentTypes: [.pdf, .presentation, .image],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let selectedFiles = try result.get()
                            fileURL = selectedFiles.first
                            uploadFile(groupId: selectedGroup.groupId, fileUrl: fileURL!) {
                                showFileList(completion: { fileList in
                                    self.files = fileList
                                }, selectedGroup.groupId)
                            }
                            //uploadFile(groupId: groupId, fileUrl: fileURL!)
                        } catch {
                            // Handle error
                        }
                    }
                //파일 목록 서버와 동기화
                Button(action : {
                        showFileList(completion: { fileList in
                            self.files = fileList
                        }, selectedGroup.groupId)
                }){
                    VStack{
                        Image(systemName: "icloud.and.arrow.down").font(.system(size: 25, weight: .ultraLight))
                    }
                }
            }
            .padding()
            //걍 파일 목록 보여주기
            ScrollView{
                LazyVGrid(columns: columns){
                    ForEach(files) { file in
                        VStack{
//                            if file.fileName.hasSuffix(".draw") {
//                                Image(systemName: "note").font(.system(size: 100, weight: .ultraLight))
//                                    .foregroundColor(Color.cyan).padding(.top)
//                            } else {
//                                Image(systemName: "doc.plaintext").font(.system(size: 100, weight: .ultraLight))
//                                    .foregroundColor(Color.cyan).padding(.top)
//                              }

                            if file.fileName.hasSuffix(".draw") { Image("drawFile").resizable().frame(width:100, height:100)}
                            else if file.fileName.hasSuffix(".pdf") { Image("pdfFile").resizable().frame(width:100, height:100) }
                                else {}
                            
                            HStack{
                                Text("\(file.fileName)").font(.system(size: 15, weight: .light))
                            }
                        }.onTapGesture {
                            self.selectedFile = file
                            downloadFile(n: file.fileId, fileName: file.fileName) { url in
                                fileViewModel.downloadedFileURL = url
                                fileViewModel.fileId = file.fileId
                                fileViewModel.fileName = file.fileName
                                if file.fileName.hasSuffix(".draw") {
                                    self.isShowingDraw = true
                                } else {
                                    self.isShowingPdf = true
                                }
                            }
                        }
                        .contextMenu { // <- Add this block
                                        Button(action: {
                                            self.showingDeleteAlert = true
                                            self.selectedFile = file
                                        }) {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }
                                    .alert(isPresented: $showingDeleteAlert) {
                                        Alert(title: Text("파일 삭제"),
                                              message: Text("이 파일을 서버에서 삭제하시겠습니까?"),
                                              primaryButton: .destructive(Text("삭제")) {
                                            deleteFile(groupId: selectedGroup.groupId, fileName: selectedFile!.fileName) {
                                                showFileList(completion: { fileList in
                                                    self.files = fileList
                                                }, selectedGroup.groupId)
                                            }
                                              },
                                              secondaryButton: .cancel(Text("취소")))
                                    }
                        .fullScreenCover(isPresented: $isShowingPdf) {
                                        if let url = fileViewModel.downloadedFileURL {
                                            PDF_FileView(url: url)
                                        }
                                    }
                        .fullScreenCover(isPresented: $isShowingDraw) {
                            if let url = fileViewModel.downloadedFileURL {
                                DrawView(drawingModel: DrawingModel(fileId: fileViewModel.fileId!, fileName: fileViewModel.fileName!, url: url, groupId: selectedGroup.groupId, userId: userId! ))
                            }
                        }
                    }
                }
            }
            //빈 노트
//            ScrollView{
//                LazyVGrid(columns: columns) {
//                    ForEach(draws) { draw in
//                        NavigationLink(destination: DrawView(drawID: draw.id, drawName : draw.drawFileName)) {
//                            VStack {
//                                Image(systemName: "doc.richtext").font(.system(size: 100))
//                                Text(draw.drawFileName)
//                            }.foregroundColor(.black)
//                        }
//                    }
//                }
//            }
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

