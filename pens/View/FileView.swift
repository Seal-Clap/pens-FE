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
    
    
    @ObservedObject var viewModel: AudioCallViewModel
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
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
            }
            ScrollView{
                LazyVGrid(columns: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Columns@*/[GridItem(.fixed(200))]/*@END_MENU_TOKEN@*/) {
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    Button(action: {self.viewModel.connectRoom(roomID: "1")}) { Text("Connect")}
                    Text("Placeholder")
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
                    Button(action: {
                        let destination: DownloadRequest.Destination = { _, _ in
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let fileURL = documentsURL.appendingPathComponent("testfile.pdf")
                            
                            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                        }
                        AF.download(
                            APIContants.baseURL+"/file/download?groupId=1000&fileName=testfile.pdf",
                            to: destination)
                        .downloadProgress { progress in
                            print("Download Progress: \(progress.fractionCompleted)")
                        }
                        .response { response in
                            if response.error == nil, let filePath = response.fileURL?.path {
                                print("File downloaded successfully: \(filePath)")
                            }
                        }
                    }) {Text("Test file download")}
                }
            }
            /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
            /*@START_MENU_TOKEN@*/Text("Placeholder")/*@END_MENU_TOKEN@*/
            Button(action: {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("testfile.pdf")
                do {
                    let fileData = try Data(contentsOf: fileURL)
                    print("file data is empty: \(fileData.isEmpty), \(fileData.description)")
                    // file data 접근 하는 부분
                } catch {
                    print("Error loading data: \(error)")
                }
            }) {Text("access testfile.pdf")}
        }
    }
    //
}

struct FileView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var groupId: Int = 0
        var body: some View {
            FileView(groupId: $groupId, viewModel: AudioCallViewModel())
        }
    }
    static var previews: some View {
        PreviewWrapper()
    }
}


