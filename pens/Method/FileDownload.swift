//
//  FileDownload.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import Foundation
import Alamofire

func downloadFile(n: Int, fileName: String, completion: @escaping (URL) -> Void) {
    let urlString = "\(APIContants.fileDownloadURl)/\(n)"

    let destination: DownloadRequest.Destination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    AF.download(urlString, to: destination).response { response in
        debugPrint(response)
        if response.error == nil, let path = response.fileURL {
            completion(path)
        }
    }
}
/*
func downloadFile(n: Int, completion: @escaping (URL) -> Void) {
    let urlString = "\(APIContants.fileDownloadURl)/\(n)"

    let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("file\(n).pdf")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        AF.download(urlString, to: destination).response { response in
            debugPrint(response)
            if response.error == nil, let path = response.fileURL {
                completion(path)
            }
        }
}
*/
