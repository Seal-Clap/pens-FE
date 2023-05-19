//
//  DrawingConfig.swift
//  pens
//
//  Created by 최진현 on 2023/05/19.
//

import Foundation

fileprivate let defaultDrawingServer = "ws://13.209.120.19:8080/ws"

struct DrawingConfig {
    let drawingServer: String
    
    static let `default` = DrawingConfig(drawingServer: defaultDrawingServer)
}
