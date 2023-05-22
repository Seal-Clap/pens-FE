//
//  FileView.swift
//  pens
//
//  Created by 박상준 on 2023/05/15.
//

import SwiftUI
import Alamofire
import Combine

enum DownloadState {
    case notStarted
    case inProgress
    case completed
}

class FileViewModel: ObservableObject {
    @Published var fileURLs = [URL]()
    var cancellables = Set<AnyCancellable>()
}

struct FileView: View {
    @State private var isImporting: Bool = false
    @State private var fileURL: URL?
    //@Binding var groupId : Int
    @Binding var selectedGroup: GroupElement //userId위해
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
    //
    @ObservedObject var fileViewModel = FileViewModel()
    var downloader = DownloadAllFiles()
    @State private var groups = [GroupElement]()
    //private var cancellables = Set<AnyCancellable>()
    @State private var refresh = UUID()
    
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
            //download
                Button(action : {
                    FileDownloadView.getFileId { fileId in
                        downloadFile(n: fileId) { url in
                            fileViewModel.fileURLs.append(url)
                        }
                    }
                }
                ){
                    VStack{
                        Image(systemName: "arrow.down.doc").font(.system(size: 30))
                    }.foregroundColor(.black)
                }
            }.padding()
            //파일 목록
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(fileViewModel.fileURLs, id: \.self) { url in
                        NavigationLink(destination: PDF_FileView(url: url)) {
                            VStack {
                                Image(systemName: "doc.plaintext").font(.system(size: 100))
                                Text(url.lastPathComponent)
                            }.foregroundColor(.black)
                        }
                    }
                }
            }
//            ScrollView {
//                LazyVGrid(columns: columns) {
//                    ForEach(fileURLs, id: \.self) { url in
//                        NavigationLink(destination: PDF_FileView(url: url)) {
//                            VStack {
//                                Image(systemName: "doc.plaintext").font(.system(size: 100))
//                                Text(url.lastPathComponent)
//                            }.foregroundColor(.black)
//                        }
//                    }
//                }
//            }
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
        .onChange(of: selectedGroup) { newGroup in
            fetchAndDownloadFiles(groupId: newGroup.groupId)
            print("바뀐 화면 ----- \(newGroup.groupId)")
            //
        }.onAppear {
            fetchAndDownloadFiles(groupId: selectedGroup.groupId)
        }.onChange(of: fileViewModel.fileURLs) { newValue in
            self.refresh = UUID()
        }
//        .onAppear {
//            fetchAndDownloadFiles(groupId: groupId)
//        }
        
    }
    //
    func fetchAndDownloadFiles(groupId : Int) {
        downloader.fetchFileList(groupId: groupId) { fileList in
            let convertedFileList = fileList.map { FileElement(fileName: $0.fileName, fileId: $0.fileId) }
            downloader.downloadFiles(fileList: convertedFileList)
                .sink(receiveCompletion: { [weak fileViewModel] completion in
                    switch completion {
                    case .failure(let error):
                        print("Error while downloading files: \(error)")
                    case .finished:
                        print("All files downloaded.")
                    }
                }, receiveValue: { [weak fileViewModel] url in
                    DispatchQueue.main.async {
                        guard let fileViewModel = fileViewModel else {
                            return
                        }
                        guard !fileViewModel.fileURLs.contains(url) else {
                            return // 중복된 URL인 경우 추가하지 않음
                        }
                        fileViewModel.fileURLs.append(url)

                        // 파일 존재 여부 확인 코드 추가
                        do {
                            var isDirectory: ObjCBool = false
                            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
                                if isDirectory.boolValue {
                                    // url points to a directory
                                    print("The directory \(url.path) exists")
                                } else {
                                    // url points to a file
                                    print("The file \(url.path) exists")
                                }
                            } else {
                                print("The item \(url.path) does not exist")
                            }
                        } catch let error as NSError {
                            print("An error took place: \(error)")
                        }

                        print("fetchAndDownloadFiles ---- url: \(url)")
                        print("fetchAndDownloadFiles ---- fileURLs: \(fileViewModel.fileURLs)")
                    }
                })
                .store(in: &self.fileViewModel.cancellables)
        }
    }

    
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

/**
 func fetchAndDownloadFiles(groupId : Int) {
     downloader.fetchFileList(groupId: groupId) { fileList in
         let convertedFileList = fileList.map { FileElement(fileName: $0.fileName, fileId: $0.fileId) }
         downloader.downloadFiles(fileList: convertedFileList)
             .sink(receiveCompletion: { [weak fileViewModel] completion in
                 switch completion {
                 case .failure(let error):
                     print("Error while downloading files: \(error)")
                 case .finished:
                     print("All files downloaded.")
                 }
             }, receiveValue: { [weak fileViewModel] url in
                 DispatchQueue.main.async {
                     guard let fileViewModel = fileViewModel else {
                         return
                     }
                     guard !fileViewModel.fileURLs.contains(url) else {
                         return // 중복 url 추가x
                     }
                     fileViewModel.fileURLs.append(url)
                     print("fetchAndDownloadFiles ---- url: \(url)")
                     print("fetchAndDownloadFiles ---- fileURLs: \(fileViewModel.fileURLs)")
                 }
             })
             .store(in: &self.fileViewModel.cancellables)
     }
 }
 */
