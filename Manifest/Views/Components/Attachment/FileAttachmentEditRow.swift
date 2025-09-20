//
//  FileAttachmentEditRow.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI

struct FileAttachmentEditRow: View {
    @Bindable var attachment: FileAttachment
    let attachments: [FileAttachment]
    let onDownload: () -> Void
    let onDelete: () -> Void
    @State private var isEditingDescription = false
    @State private var showingPreview = false
    
    // Find the index of this attachment in the full list
    private var attachmentIndex: Int {
        attachments.firstIndex(where: { $0.id == attachment.id }) ?? 0
    }
    
    // Check if this is a QR code file
    private var isQRCode: Bool {
        attachment.filename.hasPrefix("QR_Code_") && attachment.filename.hasSuffix(".png")
    }
    
    private var fileTypeColor: Color {
        switch attachment.fileType {
        case .image: return .green
        case .video: return .blue
        case .audio: return .purple
        case .document: return .orange
        case .other: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // File type icon with color coding - make it tappable for preview
                Button(action: {
                    showingPreview = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(fileTypeColor.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        if attachment.isImage, let image = UIImage(data: attachment.fileData) {
                            // Show actual image preview for photos
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            // Show file type icon for non-images
                            Image(systemName: attachment.fileIcon)
                                .foregroundStyle(fileTypeColor)
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // Filename - also tappable for preview
                    HStack {
                        Button(attachment.filename) {
                            showingPreview = true
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        // File type badge
                        Text(attachment.fileType.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(fileTypeColor.opacity(0.2))
                            .foregroundStyle(fileTypeColor)
                            .cornerRadius(4)
                    }
                    
                    HStack(spacing: 8) {
                        Text(attachment.formattedFileSize)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        
                        Text(attachment.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Action button - only download, edit description, and delete
                        Menu {
                            Button("Download") {
                                onDownload()
                            }
                            
                            if !isQRCode {
                                Button("Edit Description") {
                                    isEditingDescription = true
                                }
                            }
                            
                            Button("Delete", role: .destructive) {
                                onDelete()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            // Description section
            if isEditingDescription && !isQRCode {
                HStack {
                    TextField("Description", text: $attachment.fileDescription)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            isEditingDescription = false
                        }
                    
                    Button("Done") {
                        isEditingDescription = false
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            } else if !attachment.fileDescription.isEmpty && attachment.fileDescription != attachment.filename {
                HStack {
                    Text(attachment.fileDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
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
        .cornerRadius(12)
        .sheet(isPresented: $showingPreview) {
            MultiFilePreviewView(attachments: attachments, initialIndex: attachmentIndex)
        }
    }
}
