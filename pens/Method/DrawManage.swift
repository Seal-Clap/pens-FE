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

    func saveDrawing(_ canvas: PKCanvasView, withID id: UUID) {
        let fileURL = documentDirectory.appendingPathComponent("\(id.uuidString).draw")

        do {
            let drawingData = canvas.drawing.dataRepresentation()
            try drawingData.write(to: fileURL)
        } catch {
            print("Error saving drawing: \(error)")
        }
    }

    func loadDrawing(into canvas: PKCanvasView, withID id: UUID) {
        let fileURL = documentDirectory.appendingPathComponent("\(id.uuidString).draw")

        do {
            let drawingData = try Data(contentsOf: fileURL)
            let drawing = try PKDrawing(data: drawingData)
            canvas.drawing = drawing
        } catch {
            print("Error loading drawing: \(error)")
        }
    }
}
