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
    let drawingClient = DrawingClient()
    let webSocketDrawingClient = WebSocketDrawingClient()
    @State private var webSocketDelegate: DrawViewWebSocketDelegate?
    
    
    var body: some View {
        VStack {
            Text("\(drawName)")
            CanvasView(canvas: $canvas, toolPicker: $toolPicker, drawingClient: drawingClient, webSocketDrawingClient: webSocketDrawingClient, roomId: drawID.uuidString)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    self.webSocketDelegate = DrawViewWebSocketDelegate(canvas: canvas)
                    webSocketDrawingClient.delegate = webSocketDelegate
                }
        }
        .onAppear {
            toolPicker.setVisible(true, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
            DrawFileManager.shared.loadDrawing(into: canvas, withID: drawID)
            
            if let url = URL(string: drawingClient.roomURL(roomID: "1")) {
                //print("debug1 \(drawID.uuidString)")
                webSocketDrawingClient.connect(url: url)
            }
        }
        .onDisappear{
            DrawFileManager.shared.saveDrawing(canvas, withID: drawID)
                webSocketDrawingClient.disconnect()
        }
    }
}

class DrawViewWebSocketDelegate: WebSocketDrawingClientDelegate {
    var canvas: PKCanvasView
    var receivingDrawing: Bool = false
    
    init(canvas: PKCanvasView) {
        self.canvas = canvas
    }
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: Data) {
        print("websocket handling")
        DispatchQueue.main.async {
        
            self.receivingDrawing = true
            if let drawing = try? PKDrawing(data: data) {
                self.canvas.drawing = drawing
                print("networking drawing success")
            } else {
                // handle error
                print("networking drawing error")
            }
            
            self.receivingDrawing = false
        }
    }
    
    // Implementation for WebSocketClientDelegate
    func webSocketDidConnect(_ webSocket: WebSocketDrawingClient) {
        // Handle WebSocket connection event
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketDrawingClient) {
        // Handle WebSocket disconnection event
    }
    
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: String) {
        // Handle incoming message event
    }
}

struct CanvasView: UIViewRepresentable {
    @Binding var canvas: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    var drawingClient: DrawingClient
    var webSocketDrawingClient: WebSocketDrawingClient
    var roomId: String
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        canvas.delegate = coordinator
        return coordinator
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1
        scrollView.delegate = context.coordinator
        scrollView.addSubview(canvas)
        
        canvas.drawingPolicy = .anyInput
        canvas.frame = CGRect(x: 0, y: 0, width: 10000, height: 10000)
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false
        
        DispatchQueue.main.async {
            let canvasCenter = CGPoint(x: self.canvas.frame.midX - scrollView.bounds.midX, y: self.canvas.frame.midY - scrollView.bounds.midY)
            scrollView.setContentOffset(canvasCenter, animated: false)
        }
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.frame = canvas.frame
    }
}
    
    class Coordinator: NSObject, UIScrollViewDelegate, PKCanvasViewDelegate{
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.canvas
        }
        
        /*
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            let drawData = canvasView.drawing.dataRepresentation()
            parent.drawingClient.sendDrawingData(drawData, roomId: "1", type: "drawing", websocket: parent.webSocketDrawingClient) {
                print("send drawData[\(drawData)]")
            }
        }*/
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            guard let delegate = parent.webSocketDrawingClient.delegate as? DrawViewWebSocketDelegate,
                  !delegate.receivingDrawing else {
                return
            }
            
            let drawData = canvasView.drawing.dataRepresentation()
            parent.drawingClient.sendDrawingData(drawData, roomId: "1", type: "drawing", websocket: parent.webSocketDrawingClient) {
                print("send drawData[\(drawData)]")
            }
        }
    }

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView(drawID: UUID(), drawName: "Test Drawing")
    }
}
