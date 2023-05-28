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
    var canvasPressing = false
    var bufferedDrawingData: Data?
    
    init(fileId: Int, fileName: String, url: URL, groupId: Int) {
        self.fileId = fileId
        self.fileName = fileName
        self.url = url
        self.groupId = groupId
        
        // Configure the delegate with the new canvas reference
        self.webSocketDelegate = DrawViewWebSocketDelegate(drawingModel: self)
        self.webSocketDrawingClient.delegate = self.webSocketDelegate
    }
}

struct DrawView: View {
    @ObservedObject var drawingModel: DrawingModel
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text("\(drawingModel.fileName)")
                CanvasView(drawingModel: drawingModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        self.drawingModel.toolPicker.setVisible(true, forFirstResponder: self.drawingModel.canvas)
                        self.drawingModel.toolPicker.addObserver(self.drawingModel.canvas)
                        self.drawingModel.canvas.becomeFirstResponder()
                        DrawFileManager.shared.loadDrawing(into: self.drawingModel.canvas, fileName: self.drawingModel.fileName)
                        
                        if let url = URL(string: self.drawingModel.drawingClient.roomURL(roomID: String(self.drawingModel.fileId))) {
                            self.drawingModel.webSocketDrawingClient.connect(url: url)
                        }
                    }
            }
            .onDisappear{
                DrawFileManager.shared.saveDrawing(self.drawingModel.canvas, fileName: self.drawingModel.fileName, groupId: self.drawingModel.groupId)
                    self.drawingModel.webSocketDrawingClient.disconnect()
                    }
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


class DrawViewWebSocketDelegate: WebSocketDrawingClientDelegate {
    var drawingModel: DrawingModel
    
    init(drawingModel: DrawingModel) {
        self.drawingModel = drawingModel
    }
    
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: Data) {
        print("DrawView: websocket byte data handling")
        
        //self.receivingDrawing = true
        if self.drawingModel.canvasPressing {
            self.drawingModel.bufferedDrawingData = data
        } else {
            self.applyDrawingData(data: data)
        }
        //self.receivingDrawing = false
    }
    
    func applyDrawingData(data: Data) {
        DispatchQueue.main.async {
            if let drawing = try? PKDrawing(data: data) {
                self.drawingModel.canvas.drawing = drawing
                print("networking drawing success")
            } else {
                // handle error
                print("networking drawing error")
            }
        }
    }
    
    func webSocket(_ webSocket: WebSocketDrawingClient, didReceive data: String) {
        print("DrawView: websocket string data handling")
        DispatchQueue.main.async {
            let drawData = self.drawingModel.canvas.drawing.dataRepresentation()
            self.drawingModel.drawingClient.sendDrawingData(drawData, websocket: self.drawingModel.webSocketDrawingClient) {
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
    @ObservedObject var drawingModel: DrawingModel
    
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(self)
        drawingModel.canvas.delegate = coordinator
        return coordinator
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let canvas = drawingModel.canvas
        
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
            let canvasCenter = CGPoint(x: canvas.frame.midX - scrollView.bounds.midX, y: canvas.frame.midY - scrollView.bounds.midY)
            scrollView.setContentOffset(canvasCenter, animated: false)
        }
        
        return scrollView
    }
    
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.frame = drawingModel.canvas.frame
    }
}
    
    class Coordinator: NSObject, UIScrollViewDelegate, PKCanvasViewDelegate{
        var parent: CanvasView
        
        var localDrawing = false
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return parent.drawingModel.canvas
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            parent.drawingModel.canvasPressing = true
        }
        
        func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            
            parent.drawingModel.canvasPressing = false
            if let data = parent.drawingModel.bufferedDrawingData {
                parent.drawingModel.webSocketDelegate?.applyDrawingData(data: data)
                parent.drawingModel.bufferedDrawingData = nil
            }
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
                parent.drawingModel.drawingClient.sendDrawingData(drawData, websocket: parent.drawingModel.webSocketDrawingClient) {
                    print("send drawData[\(drawData)]")
                }
                localDrawing = false
            }
        }
    }

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView(drawingModel: DrawingModel(fileId: 1, fileName: "", url: URL(string:"")!, groupId: 1))
    }
}
