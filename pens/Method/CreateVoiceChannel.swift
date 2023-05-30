//
//  CreateVoiceChannel.swift
//  pens
//
//  Created by 박상준 on 2023/05/30.
//

import Foundation
import Alamofire

func createNewChannel(groupId : Int, channelName : String, completion: @escaping () -> Void) {
    guard let url = URL(string: APIContants.channelURL)
        else { return }
    
    let parameters : [String: Any] = ["groupId": groupId, "channelName": channelName]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
    request.httpBody = jsonData
    
    AF.request(request).response { response in
        switch response.result {
        case .success:
            completion()
        case let .failure(error):
            print(error)
        }
    }
}
