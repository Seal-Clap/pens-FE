//
//  DrawManage.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import PencilKit

struct DrawFileManager {
    static let shared = DrawFileManager()

    private let fileManager = FileManager.default
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    private init() {}

    func saveDrawing(_ canvas: PKCanvasView, fileName: String, groupId: Int) {
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")

        do {
            let drawingData = canvas.drawing.dataRepresentation()
            try drawingData.write(to: fileURL)
        } catch {
            print("Error saving drawing: \(error)")
        }
        
        uploadFile(groupId: groupId, fileUrl: fileURL) {}
    }

    func loadDrawing(into canvas: PKCanvasView, fileName: String) {
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")

        do {
            let drawingData = try Data(contentsOf: fileURL)
            let drawing = try PKDrawing(data: drawingData)
            canvas.drawing = drawing
        } catch {
            print("Error loading drawing: \(error)")
        }
    }
    
    func initDrawing(fileName: String, groupId: Int, completion: @escaping() -> Void) {
        let fileURL = documentDirectory.appendingPathComponent("\(fileName)")
        let emptyDrawing = PKDrawing()
        do {
            let drawingData = emptyDrawing.dataRepresentation()
            try drawingData.write(to: fileURL)
        } catch {
            print("Error init drawing: \(error)")
        }
        uploadFile(groupId: groupId, fileUrl: fileURL, completion: completion)
    }
}
