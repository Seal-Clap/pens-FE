//
//  Folder.swift
//  pens
//
//  Created by 박상준 on 2023/05/13.
//

import Foundation
import SwiftUI

struct Folder: Identifiable {
    var id = UUID()
    var folderName: String
}
struct FolderName {
    static func setFolderName(folders: Binding<[Folder]>, isPresented: Binding<Bool>) {
        let alert = UIAlertController(title: "새 폴더", message: "새 폴더의 이름을 입력하세요", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "추가", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                folders.wrappedValue.append(Folder(folderName: text))
            }
            isPresented.wrappedValue = false
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

