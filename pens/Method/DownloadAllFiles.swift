//
//  DownloadAllFiles.swift
//  pens
//
//  Created by 박상준 on 2023/05/21.
//

import Foundation
import Alamofire
import Combine

struct FileElement: Decodable {
    let fileName: String
    let fileId: Int
}

class DownloadAllFiles {
    // fileId와 fileName을 받아오는 함수
    func fetchFileList(groupId: Int, completion: @escaping ([FileElement]) -> Void) {
        let urlString = APIContants.baseURL + "/file?groupId=\(groupId)"
        
        AF.request(urlString).responseDecodable(of: [FileElement].self) { response in
            switch response.result {
            case .success(let fileElements):
                completion(fileElements)
                print("Fetched fileList: \(fileElements)")
            case .failure(let error):
                print("Error while fetching files: \(error)")
            }
        }
    }
    
    // 실제 파일을 다운로드하는 함수
    func downloadFiles(fileList: [FileElement]) -> AnyPublisher<URL, Error> {
        let pdfFiles = fileList.filter { $0.fileName.hasSuffix(".pdf") }
        
        let publishers = pdfFiles.map { fileElement -> AnyPublisher<URL, Error> in
            let urlString = APIContants.baseURL + "/file/download/\(fileElement.fileId)"
            print("dowloadFile / id /  ---- \(fileElement.fileId)")
            
            let destination: DownloadRequest.Destination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent(fileElement.fileName)
                print("downloadFile / name / -- \(fileElement.fileName)")
                
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            return AF.download(urlString, to: destination)
                .downloadProgress { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                }
                .publishDecodable(type: URL.self)
                .compactMap { $0.value }
                .catch { error -> AnyPublisher<URL, Error> in // Here we handle the error
                    return Fail(error: error).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(publishers).eraseToAnyPublisher()
    }
}


