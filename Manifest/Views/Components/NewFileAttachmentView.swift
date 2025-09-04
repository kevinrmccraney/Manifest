//
//  NewFileAttachmentView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct NewFileAttachmentView: View {
    let fileURL: URL
    @Binding var attachmentDescription: String
    let onChangeFile: () -> Void
    let onRemoveFile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: getFileIcon(for: fileURL.pathExtension))
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(fileURL.lastPathComponent)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if let fileSize = getFileSize(for: fileURL) {
                        Text(fileSize)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
            }
            
            TextField("File description", text: $attachmentDescription)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Change File") {
                    onChangeFile()
                }
                .buttonStyle(.bordered)
                
                Button("Remove File") {
                    onRemoveFile()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getFileIcon(for extension: String) -> String {
        switch `extension`.lowercased() {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.fill.on.rectangle.fill"
        case "txt": return "doc.text"
        case "jpg", "jpeg", "png", "gif": return "photo.fill"
        case "mp4", "mov", "avi": return "video.fill"
        case "mp3", "wav", "m4a": return "music.note"
        case "zip", "rar": return "archivebox.fill"
        default: return "doc.fill"
        }
    }
    
    private func getFileSize(for url: URL) -> String? {
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return nil
    }
}
