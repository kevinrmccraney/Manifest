//
//  FileAttachmentEditRow.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//


//
//  FileAttachmentEditRow.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI

struct FileAttachmentEditRow: View {
    @Bindable var attachment: FileAttachment
    let onDownload: () -> Void
    let onDelete: () -> Void
    @State private var isEditingDescription = false
    
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
                // File type icon with color coding
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(fileTypeColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: attachment.fileIcon)
                        .foregroundStyle(fileTypeColor)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Filename - not tappable in edit mode
                    HStack {
                        Text(attachment.filename)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
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
    }
}