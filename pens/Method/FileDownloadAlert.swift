//
//  FileDownload.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import Foundation
import SwiftUI
import UIKit

struct FileDownloadView {
    static func getFileId(downloadAction: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: "파일 다운로드", message: "다운받을 파일 ID를 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "다운로드", style: .default) { _ in
            if let fileIdString = alert.textFields?.first?.text,
               let fileId = Int(fileIdString) {
                downloadAction(fileId)
            }
        })
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

