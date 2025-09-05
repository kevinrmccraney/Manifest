//
//  QRCodeGeneratorContent.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCodeGeneratorContent: View {
    let item: Item?
    let itemName: String
    let itemID: UUID
    @Binding var attachments: [FileAttachment]
    @State private var isGenerating = false
    
    // Check if QR code already exists
    private var hasQRCode: Bool {
        attachments.contains { attachment in
            attachment.filename.hasPrefix("QR_Code_") && attachment.filename.hasSuffix(".png")
        }
    }
    
    var body: some View {
        if !hasQRCode {
            Button(action: generateQRCode) {
                HStack {
                    Image(systemName: "qrcode")
                        .foregroundStyle(.blue)
                    Text("Generate QR Code")
                    Spacer()
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .disabled(isGenerating)
        } else {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("QR Code generated")
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .font(.subheadline)
        }
    }
    
    private func generateQRCode() {
        print("Starting QR code generation for item: \(itemName)")
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Generate QR code image using the same URL format as NFC
            let urlString = "manifest://item/\(itemID.uuidString)"
            let qrImage = generateQRCodeImage(for: urlString)
            
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
