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
    @State private var showingDownloadMenu = false
    @State private var selectedAttachment: FileAttachment?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachments (\(totalAttachmentCount))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            // New multi-file attachments
            if !item.attachments.isEmpty {
                ForEach(item.attachments, id: \.id) { attachment in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: attachment.fileIcon)
                                .foregroundStyle(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                // Make the entire description area tappable for preview
                                HStack {
                                    Text(attachment.fileDescription)
                                        .font(.body)
                                        .lineLimit(1)
                                        .foregroundStyle(.primary)
                                    
                                    Text("Preview")
                                        .font(.caption)
                                        .foregroundStyle(.clear) // Invisible text
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    previewAttachment = attachment
                                    showingPreview = true
                                }
                                
                                Text(attachment.formattedFileSize)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // Chevron button for download menu
                            Button(action: {
                                selectedAttachment = attachment
                                showingDownloadMenu = true
                            }) {
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Legacy attachment support
            if item.attachmentData != nil {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: item.fileIcon)
                            .foregroundStyle(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            // Make the entire description area tappable for preview
                            HStack {
                                Text(item.attachmentDescription ?? item.attachmentFilename ?? "Unknown file")
                                    .font(.body)
                                    .lineLimit(1)
                                    .foregroundStyle(.primary)
                                
                                Text("Preview")
                                    .font(.caption)
                                    .foregroundStyle(.clear) // Invisible text
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                previewLegacyAttachment()
                            }
                            
                            if let data = item.attachmentData {
                                Text("\(data.count.formatted(.byteCount(style: .file)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Chevron button for legacy download menu
                        Button(action: {
                            downloadLegacyFile()
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
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
        .confirmationDialog("File Options", isPresented: $showingDownloadMenu) {
            Button("Download") {
                if let attachment = selectedAttachment {
                    downloadFile(attachment)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func previewLegacyAttachment() {
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
