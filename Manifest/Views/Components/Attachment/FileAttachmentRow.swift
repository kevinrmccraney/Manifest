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
    @State private var showingDownloadMenu = false
    
    // Check if this is a QR code file
    private var isQRCode: Bool {
        attachment.filename.hasPrefix("QR_Code_") && attachment.filename.hasSuffix(".png")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: attachment.fileIcon)
                    .foregroundStyle(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    // Make the entire description area tappable for preview with invisible "Preview" text
                    HStack {
                        Text(attachment.filename)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text("Preview")
                            .font(.caption)
                            .foregroundStyle(.clear) // Invisible text
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onPreview()
                    }
                    
                    Text(attachment.formattedFileSize)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Chevron button for download menu
                Button(action: {
                    showingDownloadMenu = true
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .confirmationDialog("File Options", isPresented: $showingDownloadMenu) {
                    Button("Download") {
                        onDownload()
                    }
                    Button("Delete", role: .destructive) {
                        onDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                }
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
                        .foregroundStyle(.primary)
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
                        .foregroundStyle(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
