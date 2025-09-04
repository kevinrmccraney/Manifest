//
//  ExistingFileAttachmentView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ExistingFileAttachmentView: View {
    let item: Item
    @Binding var attachmentDescription: String
    let onReplaceFile: () -> Void
    let onRemoveFile: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: item.fileIcon)
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.attachmentFilename ?? "Unknown file")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    if let data = item.attachmentData {
                        Text("\(data.count.formatted(.byteCount(style: .file)))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
            }
            
            TextField("File description", text: $attachmentDescription)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                Button("Replace File") {
                    onReplaceFile()
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
}
