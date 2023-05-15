//
//  Logger.swift
//  pens
//
//  Created by Lee Jeong Woo on 2023/05/14.
//

import Foundation

public func dLog(_ object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
  #if DEBUG
    let className = (fileName as NSString).lastPathComponent
    print("[\(className)] \(functionName) [#\(lineNumber)]| \(object)\n")
  #endif
}
