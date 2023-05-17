//
//  DrawView.swift
//  pens
//
//  Created by 박상준 on 2023/05/16.
//

import SwiftUI
import PencilKit

struct DrawView: View {
    var drawID: UUID
    var drawName: String

    @State private var canvas = PKCanvasView()
    @State private var toolPicker = PKToolPicker()

    var body: some View {
        VStack {
            Text("\(drawName)")
            CanvasView(canvas: $canvas, toolPicker: $toolPicker)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        .onAppear {
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
            DrawFileManager.shared.loadDrawing(into: canvas, withID: drawID)
        }
        .onDisappear{
            DrawFileManager.shared.saveDrawing(canvas, withID: drawID)
        }
    }
}
struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var toolPicker: PKToolPicker

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = context.coordinator
        scrollView.addSubview(canvas)

        canvas.drawingPolicy = .anyInput
        canvas.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.frame = canvas.frame
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.canvas
        }
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView(drawID: UUID(), drawName: "Test Drawing")
    }
}
