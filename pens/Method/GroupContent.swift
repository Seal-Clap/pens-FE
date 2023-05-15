//
//  GroupContent.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/12.
//

//import Foundation
//import Alamofire
//
//struct GroupContent {
//    func uploadFile(groupId: Int, fileUrl: URL) {
//        let url = URL(string: APIContants.fileUploadURL)!
//
//            AF.upload(multipartFormData: { multipartFormData in
//                multipartFormData.append(fileUrl, withName: "file")
//                multipartFormData.append(Data("\(groupId)".utf8), withName: "groupId")
//            }, to: url)
//            .responseJSON { response in
//                debugPrint(response)
//            }
//        }
//}
