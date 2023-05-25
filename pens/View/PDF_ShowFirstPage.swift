//
//  PDF_ShowFirstPage.swift
//  pens
//
//  Created by 박상준 on 2023/05/25.
//

import PDFKit
import SwiftUI

struct PDF_SwhoFirstPage: View {
    let urls: [URL]
    
    var body: some View {
        if let image = generateThumbnail() {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
    
    func generateThumbnail() -> UIImage? {
        guard let pdfDocument = mergePDF(urls: urls) else {
            return nil
        }
        
        guard let pdfPage = pdfDocument.page(at: 0) else {
            return nil
        }
        
        let pdfThumbnailSize = CGSize(width: 60, height: 80)
        let thumbnailRect = CGRect(x: 0, y: 0, width: 60, height: 80)
        
        return pdfPage.thumbnail(of: pdfThumbnailSize, for: .mediaBox)
    }
    
    func mergePDF(urls: [URL]) -> PDFDocument? {
        let outputPDFDocument = PDFDocument()
        
        for url in urls {
            if let inputPDFDocument = PDFDocument(url: url) {
                let pageCount = inputPDFDocument.pageCount
                for i in 0..<pageCount {
                    if let page = inputPDFDocument.page(at: i) {
                        outputPDFDocument.insert(page, at: outputPDFDocument.pageCount)
                    }
                }
            }
        }
        
        return outputPDFDocument
    }
}

