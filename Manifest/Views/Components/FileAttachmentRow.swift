//
//  FileAttachmentRow.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct FileAttachmentRow: View {
    @Bindable var attachment: FileAttachment
    let onPreview: () -> Void
    let onDownload: () -> Void
    let onDelete: () -> Void
    @State private var isEditingDescription = false
    
    // Check if this is a QR code file
    private var isQRCode: Bool {
        attachment.filename.hasPrefix("QR_Code_") && attachment.filename.hasSuffix(".png")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: onPreview) {
                    HStack {
                        Image(systemName: attachment.fileIcon)
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(attachment.filename)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Text(attachment.formattedFileSize)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "eye.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Add download button
                Button(action: onDownload) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
            
            HStack {
                if isEditingDescription && !isQRCode {
                    TextField("Description", text: $attachment.fileDescription)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            isEditingDescription = false
                        }
                } else {
                    Text(attachment.fileDescription)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            if !isQRCode {
                                isEditingDescription = true
                            }
                        }
                    
                    Spacer()
                    
                    if !isQRCode {
                        Button("Edit") {
                            isEditingDescription = true
                        }
                        .font(.caption2)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
