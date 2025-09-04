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
    let itemName: String  // Add item name parameter
    let itemID: UUID      // Add item ID parameter
    @Binding var attachments: [FileAttachment]
    @State private var showingQRGenerator = false
    @State private var isGenerating = false
    
    // Check if QR code already exists
    private var hasQRCode: Bool {
        attachments.contains { attachment in
            attachment.filename.hasPrefix("QR_Code_") && attachment.filename.hasSuffix(".png")
        }
    }
    
    var body: some View {
        Section(header: Text("QR Code")) {
            if !hasQRCode {
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
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("QR Code generated")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
    }
    
    private func generateQRCode() {
        print("Starting QR code generation for item: \(itemName)")
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
            
            // Create file attachment with item name
            let qrAttachment = FileAttachment(
                filename: "QR_Code_\(itemName.replacingOccurrences(of: " ", with: "_")).png",
                fileDescription: "QR Code for \(itemName)",
                fileData: pngData,
                mimeType: "image/png"
            )
            
            print("Created QR attachment with ID: \(qrAttachment.id)")
            
            DispatchQueue.main.async {
                attachments.append(qrAttachment)
                print("Added QR code attachment. Total attachments: \(attachments.count)")
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
