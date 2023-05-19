//
//  PDF_FileView.swift
//  pens
//
//  Created by 박상준 on 2023/05/17.
//

import SwiftUI
import PDFKit
struct PDF_FileView: View {
    var url: URL

        var body: some View {
            PDFKitRepresentedView(url)
                .edgesIgnoringSafeArea(.all)
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


