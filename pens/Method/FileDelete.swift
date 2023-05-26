//
//  FileDelete.swift
//  pens
//
//  Created by 최진현 on 2023/05/26.
//

import Foundation
import Alamofire

func deleteFile(groupId: Int, fileName: String, completion: @escaping () -> Void) {
    guard let url = URL(string: "\(APIContants.fileDeleteURl)")
        else { return }
    
    let parameters: [String: Any] = [
        "groupId": groupId,
        "fileName": fileName
    ]
    
    do {
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                debugPrint(response)
                completion()
            case .failure(let error):
                print(error)
            }
        }
    } catch {
        print("Unable to load data: \(error)")
    }
}
