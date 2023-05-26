//
//  FileUpload.swift
//  pens
//
//  Created by 박상준 on 2023/05/15.
//

import Foundation
import Alamofire

func uploadFile(groupId: Int, fileUrl: URL, completion: @escaping () -> Void) {
    guard let url = URL(string: "\(APIContants.fileUploadURL)?groupId=\(groupId)")
        else { return }
    
    do {
        let fileData = try Data(contentsOf: fileUrl)
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileData, withName: "file", fileName: fileUrl.lastPathComponent)
        }, to: url, method: .post).validate(statusCode: 200..<300)
            .response { response in
                debugPrint(response)
                completion()
            }
    } catch {
        print("Unable to load data: \(error)")
    }
}

