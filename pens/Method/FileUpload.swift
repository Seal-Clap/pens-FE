//
//  FileUpload.swift
//  pens
//
//  Created by 박상준 on 2023/05/15.
//

import Foundation
import Alamofire

func uploadFile(groupId: Int, fileUrl: URL, completion: @escaping () -> Void) {
    let url = URL(string: "\(APIContants.fileUploadURL)?groupId=\(groupId)")!
    
    var didStartAccessing = false
    
    // If the file is a .pdf, try to start accessing the security scoped resource
    if fileUrl.pathExtension.lowercased() == "pdf" {
        didStartAccessing = fileUrl.startAccessingSecurityScopedResource()
        
        guard didStartAccessing else {
            // Handle the failure here.
            return
        }
    }
    
    // Make sure you release the security-scoped resource when you finish, only if we started accessing it
    defer { if didStartAccessing { fileUrl.stopAccessingSecurityScopedResource() } }
    
    do {
        let fileData = try Data(contentsOf: fileUrl)
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileData, withName: "file", fileName: fileUrl.lastPathComponent)
        }, to: url, method: .post).validate(statusCode: 200..<300)
            .response { response in
                debugPrint(response)
                completion() // call completion handler here
            }
    } catch {
        print("Unable to load data: \(error)")
    }
}
