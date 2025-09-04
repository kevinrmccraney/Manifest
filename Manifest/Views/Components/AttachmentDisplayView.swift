//
//  AttachmentDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct AttachmentDisplayView: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachment")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: item.fileIcon)
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.attachmentDescription ?? item.attachmentFilename ?? "Unknown file")
                        .font(.body)
                        .lineLimit(1)
                    
                    if let data = item.attachmentData {
                        Text("\(data.count.formatted(.byteCount(style: .file)))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
