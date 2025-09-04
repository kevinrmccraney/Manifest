    //
//  QRCodeGeneratorSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//


//
//  QRCodeGeneratorSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeGeneratorSection: View {
    let item: Item?
    @Binding var attachments: [FileAttachment]
    @State private var showingQRGenerator = false
    @State private var isGenerating = false
    
    var body: some View {
        Section(header: Text("QR Code")) {
            Button(action: generateQRCode) {
                HStack {
                    Image(systemName: "qrcode")
                    Text("Generate QR Code for Item")
                    if isGenerating {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .disabled(isGenerating)
            .buttonStyle(.bordered)
        }
    }
    
    private func generateQRCode() {
        guard let itemID = item?.id else { return }
        
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Generate QR code image
            let qrImage = generateQRCodeImage(for: itemID.uuidString)
            
            // Convert to PNG data
            guard let pngData = qrImage.pngData() else {
                DispatchQueue.main.async {
                    isGenerating = false
                }
                return
            }
            
            // Create file attachment
            let qrAttachment = FileAttachment(
                filename: "QR_Code_\(itemID.uuidString.prefix(8)).png",
                fileDescription: "QR Code for \(item?.name ?? "Item")",
                fileData: pngData,
                mimeType: "image/png"
            )
            
            DispatchQueue.main.async {
                attachments.append(qrAttachment)
                isGenerating = false
            }
        }
    }
    
    private func generateQRCodeImage(for text: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(text.utf8)
        filter.correctionLevel = "H"
        
        if let outputImage = filter.outputImage {
            // Scale up the QR code to make it higher resolution
            let scaleX = 200.0 / outputImage.extent.size.width
            let scaleY = 200.0 / outputImage.extent.size.height
            let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        // Fallback to a simple placeholder
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}
