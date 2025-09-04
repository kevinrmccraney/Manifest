//
//  MultiAttachmentsDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct MultiAttachmentsDisplayView: View {
    let item: Item
    @State private var previewAttachment: FileAttachment?
    @State private var showingPreview = false
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachments (\(totalAttachmentCount))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // New multi-file attachments
            if !item.attachments.isEmpty {
                ForEach(item.attachments, id: \.id) { attachment in
                    HStack {
                        Button(action: {
                            previewAttachment = attachment
                            showingPreview = true
                        }) {
                            HStack {
                                Image(systemName: attachment.fileIcon)
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(attachment.fileDescription)
                                        .font(.body)
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                    
                                    Text(attachment.formattedFileSize)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "eye.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Add download button
                        Button(action: {
                            downloadFile(attachment)
                        }) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Legacy attachment support
            if item.attachmentData != nil {
                HStack {
                    Button(action: {
                        // Create temporary FileAttachment for preview
                        if let data = item.attachmentData,
                           let filename = item.attachmentFilename {
                            let tempAttachment = FileAttachment(
                                filename: filename,
                                fileDescription: item.attachmentDescription ?? filename,
                                fileData: data,
                                mimeType: "application/octet-stream"
                            )
                            previewAttachment = tempAttachment
                            showingPreview = true
                        }
                    }) {
                        HStack {
                            Image(systemName: item.fileIcon)
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.attachmentDescription ?? item.attachmentFilename ?? "Unknown file")
                                    .font(.body)
                                    .lineLimit(1)
                                    .foregroundColor(.primary)
                                
                                if let data = item.attachmentData {
                                    Text("\(data.count.formatted(.byteCount(style: .file)))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "eye.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Add download button for legacy attachment
                    Button(action: {
                        downloadLegacyFile()
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let attachment = previewAttachment {
                FilePreviewView(fileAttachment: attachment)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ActivityViewController(activityItems: [url])
            }
        }
    }
    
    private func downloadFile(_ attachment: FileAttachment) {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
        
        do {
            try attachment.fileData.write(to: tempFileURL)
            shareURL = tempFileURL
            showingShareSheet = true
        } catch {
            print("Error creating temp file for download: \(error)")
        }
    }
    
    private func downloadLegacyFile() {
        guard let data = item.attachmentData,
              let filename = item.attachmentFilename else { return }
        
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempFileURL)
            shareURL = tempFileURL
            showingShareSheet = true
        } catch {
            print("Error creating temp file for legacy download: \(error)")
        }
    }
    
    private var totalAttachmentCount: Int {
        var count = item.attachments.count
        if item.attachmentData != nil {
            count += 1
        }
        return count
    }
}
