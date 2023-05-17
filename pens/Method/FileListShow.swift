//
//  FileListShow.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import Foundation
import Alamofire

struct FileList : Codable,Identifiable {
    let id = UUID()
    let fileName : String
    let fileId : Int
    
    enum CodingKeys: String, CodingKey {
    case fileName = "fileName"
    case fileId = "fileId"
    }
}
func showFileList(completion: @escaping ([FileList]) -> (), _ groupId: Int?) {
    guard let groupId = groupId else { return }

    let parameters: [String: Any] = ["groupId": groupId]
    let url = APIContants.fileListURL
    print("url ______ \(url)")
    print("param ________ \(parameters)")

    AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).validate().responseDecodable(of: [FileList].self) { (response) in
        switch response.result {
        case .success(let fileList):
            completion(fileList)
            print(fileList)
        case .failure(let error):
            print(error)
        }
    }
}

