//
//  DrawFile.swift
//  pens
//
//  Created by 박상준 on 2023/05/16.
//

import Foundation
import SwiftUI

struct Draw: Identifiable{
    var id = UUID()
    var drawFileName: String
}

struct DrawFileName {
    static func setDrawFileName(draws: Binding<[Draw]>, isPresented: Binding<Bool>) {
        let alert = UIAlertController(title: "새 문서", message: "새 문서의 이름을 입력하세요", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "추가", style: .default) { _ in
            if let text = alert.textFields?.first?.text {
                draws.wrappedValue.append(Draw(drawFileName: text))
            }
            isPresented.wrappedValue = false
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
