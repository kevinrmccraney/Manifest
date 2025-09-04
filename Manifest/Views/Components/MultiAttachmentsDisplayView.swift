//
//  MultiAttachmentsDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//


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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachments (\(totalAttachmentCount))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            // New multi-file attachments
            if !item.attachments.isEmpty {
                ForEach(item.attachments, id: \.id) { attachment in
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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Legacy attachment support
            if item.attachmentData != nil {
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
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let attachment = previewAttachment {
                FilePreviewView(fileAttachment: attachment)
            }
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