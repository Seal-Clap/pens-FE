//
//  PDF_FileView.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

//그림 그려짐, 근데 스크롤 해도 그림은 그대로임.

import SwiftUI
import PDFKit
import PencilKit

struct PDF_FileView: View {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    @State private var drawingMode = false
    @StateObject private var viewModel = PDFKitAndPencilViewModel()
    var body: some View {
        NavigationView {
            PDFKitAndPencilRepresentedView(url: url, drawingMode: $drawingMode, viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                }, trailing: Button(action: {
                    drawingMode.toggle()
                }) {
                    Image(systemName: drawingMode ? "pencil.slash" : "pencil")
                })
        }
        .onAppear {
            viewModel.toolPicker.addObserver(viewModel)
            viewModel.toolPicker.setVisible(true, forFirstResponder: viewModel.canvasView)
            viewModel.toolPicker.addObserver(viewModel.canvasView)
            viewModel.canvasView.becomeFirstResponder()
        }
    }
}

struct PDFKitAndPencilRepresentedView: UIViewRepresentable {
    let url: URL
    @Binding var drawingMode: Bool
    @ObservedObject var viewModel: PDFKitAndPencilViewModel
    
    init(url: URL, drawingMode: Binding<Bool>, viewModel: PDFKitAndPencilViewModel) {
        self.url = url
        self._drawingMode = drawingMode
        self.viewModel = viewModel
    }
    
    func makeUIView(context: Context) -> UIView {
        // setup PDF view
        let pdfView = PDFView()
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        // setup parent view
        let parentView = UIView()
        parentView.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        // setup canvas view
        viewModel.canvasView.isOpaque = false
        viewModel.canvasView.backgroundColor = .clear
        parentView.addSubview(viewModel.canvasView)
        viewModel.canvasView.translatesAutoresizingMaskIntoConstraints = false
        
        // constraints
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: parentView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            
            viewModel.canvasView.topAnchor.constraint(equalTo: parentView.topAnchor),
            viewModel.canvasView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            viewModel.canvasView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            viewModel.canvasView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])
        
        return parentView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if drawingMode {
            viewModel.toolPicker.setVisible(true, forFirstResponder: viewModel.canvasView)
            viewModel.canvasView.isUserInteractionEnabled = true
        } else {
            viewModel.toolPicker.setVisible(false, forFirstResponder: viewModel.canvasView)
            viewModel.canvasView.isUserInteractionEnabled = false
        }
    }
}

class PDFKitAndPencilViewModel: NSObject, ObservableObject, PKCanvasViewDelegate, PKToolPickerObserver {
    var canvasView: PKCanvasView
    var toolPicker: PKToolPicker
    
    override init() {
        canvasView = PKCanvasView()
        toolPicker = PKToolPicker()
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            toolPicker = PKToolPicker.shared(for: window) ?? PKToolPicker()
        }
        
        super.init()
        canvasView.delegate = self
    }
}


//그림은 그려짐 근데 스크롤 안됨
/*
import SwiftUI
import PDFKit
import PencilKit

struct PDF_FileView: View {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            PDFKitAndPencilRepresentedView(url)
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

struct PDFKitAndPencilRepresentedView: UIViewRepresentable {
    let url: URL
    var canvasView = PKCanvasView()
    var toolPicker = PKToolPicker()
    
    init(_ url: URL) {
        self.url = url
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        var parent: PDFKitAndPencilRepresentedView

        init(_ parent: PDFKitAndPencilRepresentedView) {
            self.parent = parent
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        let pdfView = PDFView()
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        let parentView = UIView()
        parentView.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false

        canvasView.isOpaque = false // new line
        canvasView.backgroundColor = .clear // new line
        parentView.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = context.coordinator
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()

        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: parentView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            
            canvasView.topAnchor.constraint(equalTo: parentView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ])
        
        return parentView
    }

    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}
*/



//원본
/*
import SwiftUI
import PDFKit
struct PDF_FileView: View {
    var url: URL
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            PDFKitRepresentedView(url)
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
struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        
    }
}
*/
