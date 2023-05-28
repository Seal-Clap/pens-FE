//
//  DrawView.swift
//  pens
//
//  Created by 박상준 on 2023/05/16.
//

import SwiftUI
import PencilKit

class DrawingModel: ObservableObject {
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    let drawingClient = DrawingClient()
    let webSocketDrawingClient = WebSocketDrawingClient()
    var webSocketDelegate: DrawViewWebSocketDelegate? = nil
    var fileId: Int
    var fileName: String
    var url: URL
    var groupId: Int
    
    init(fileId: Int, fileName: String, url: URL, groupId: Int) {
        self.fileId = fileId
        self.fileName = fileName
        self.url = url
        self.groupId = groupId
        
        // Configure the delegate with the new canvas reference
        self.webSocketDelegate = DrawViewWebSocketDelegate(canvas: self.canvas, drawingClient: self.drawingClient, webSocketDrawingClient: self.webSocketDrawingClient, roomId: String(self.fileId))
        self.webSocketDrawingClient.delegate = self.webSocketDelegate
    }
}

struct DrawView: View {
    var fileId: Int
    var fileName: String
    var url: URL
    var groupId: Int
    
    @State private var canvas = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    let drawingClient = DrawingClient()
    let webSocketDrawingClient = WebSocketDrawingClient()
    @State private var webSocketDelegate: DrawViewWebSocketDelegate?
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(fileName)")
                CanvasView(canvas: $canvas, toolPicker: $toolPicker, drawingClient: drawingClient, webSocketDrawingClient: webSocketDrawingClient, roomId: String(fileId))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        self.webSocketDelegate = DrawViewWebSocketDelegate(canvas: canvas, drawingClient: drawingClient, webSocketDrawingClient: webSocketDrawingClient, roomId: String(fileId))
                        webSocketDrawingClient.delegate = webSocketDelegate
                    }
            }
            .onAppear {
                toolPicker.setVisible(true, forFirstResponder: canvas)
                toolPicker.addObserver(canvas)
                canvas.becomeFirstResponder()
                DrawFileManager.shared.loadDrawing(into: canvas, fileName: fileName)
                
                if let url = URL(string: drawingClient.roomURL(roomID: String(fileId))) {
                    //print("debug1 \(drawID.uuidString)")
                    webSocketDrawingClient.connect(url: url)
                }
            }
            .onDisappear{
                DrawFileManager.shared.saveDrawing(canvas, fileName: fileName, groupId: groupId)
                webSocketDrawingClient.disconnect()
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("Back")
                }
            })
        }
    }
}

class DrawViewWebSocketDelegate: WebSocketDrawingClientDelegate {
    var canvas: PKCanvasView
    var drawingClient: DrawingClient
    var webSocketDrawingClient: WebSocketDrawingClient
    var receivingDrawing: Bool = false
    var roomId: String
    
    init(canvas: PKCanvasView, drawingClient: DrawingClient, webSocketDrawingClient: WebSocketDrawingClient, roomId: String) {
        self.canvas = canvas
        self.drawingClient = drawingClient
        self.webSocketDrawingClient = webSocketDrawingClient
        self.roomId = roomId
    }
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: Data) {
        print("DrawView: websocket byte data handling")
        DispatchQueue.main.async {
        
            //self.receivingDrawing = true
            if let drawing = try? PKDrawing(data: data) {
                self.canvas.drawing = drawing
                print("networking drawing success")
            } else {
                // handle error
                print("networking drawing error")
            }
            
            //self.receivingDrawing = false
        }
    }
    
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: String) {
        print("DrawView: websocket string data handling")
        DispatchQueue.main.async {
            let drawData = self.canvas.drawing.dataRepresentation()
            self.drawingClient.sendDrawingData(drawData, roomId: self.roomId, type: "drawing", websocket: self.webSocketDrawingClient) {
                print("send drawData[\(drawData)] for init user")
            }
        }
    }
    
    // Implementation for WebSocketClientDelegate
    func webSocketDidConnect(_ webSocket: WebSocketDrawingClient) {
        // Handle WebSocket connection event
    }
    
    func webSocketDidDisconnect(_ webSocket: WebSocketDrawingClient) {
        // Handle WebSocket disconnection event
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
        var localDrawing = false
        var canvasPressing = false
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.canvas
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            canvasPressing = true
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            
            canvasPressing = false
//            let drawData = canvasView.drawing.dataRepresentation()
//            parent.drawingClient.sendDrawingData(drawData, roomId: parent.roomId, type: "drawing", websocket: parent.webSocketDrawingClient) {
//                print("send drawData[\(drawData)]")
//            }
            localDrawing = true
            
        }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            guard let delegate = parent.webSocketDrawingClient.delegate as? DrawViewWebSocketDelegate,
//                  !delegate.receivingDrawing else {
//                return
//            }
            
            if(localDrawing) {
                let drawData = canvasView.drawing.dataRepresentation()
                parent.drawingClient.sendDrawingData(drawData, roomId: parent.roomId, type: "drawing", websocket: parent.webSocketDrawingClient) {
                    print("send drawData[\(drawData)]")
                }
                localDrawing = false
            }
        }
    }

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView(fileId: 1, fileName: "temp", url: URL(string: "")!, groupId: 1)
    }
}
