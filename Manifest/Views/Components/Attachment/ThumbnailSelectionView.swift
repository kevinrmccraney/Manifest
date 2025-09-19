//
//  ThumbnailSelectionView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI

struct ThumbnailSelectionView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    let onSelectionMade: ((UIImage?) -> Void)
    
    // Get all image attachments
    private var imageAttachments: [FileAttachment] {
        item.attachments.filter { $0.isImage }
    }
    
    // Check if current thumbnail matches any attachment
    private func isCurrentThumbnail(_ attachment: FileAttachment) -> Bool {
        guard let thumbnailData = item.thumbnailData else { return false }
        return thumbnailData == attachment.fileData
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                // Current emoji option
                VStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 100)
                        .overlay(
                            Text(item.effectiveEmojiPlaceholder)
                                .font(.system(size: 40))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(item.thumbnailData == nil ? Color.blue : Color.clear, lineWidth: 3)
                        )
                        .onTapGesture {
                            onSelectionMade(nil)
                            dismiss()
                        }
                    
                    Text("Emoji")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if item.thumbnailData == nil {
                        Text("Current")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                // Image attachment options
                ForEach(imageAttachments, id: \.id) { attachment in
                    VStack {
                        if let image = UIImage(data: attachment.fileData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 100)
                                .clipped()
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isCurrentThumbnail(attachment) ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    onSelectionMade(image)
                                    dismiss()
                                }
                            
                            Text(attachment.filename)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            
                            if isCurrentThumbnail(attachment) {
                                Text("Current")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Choose Thumbnail")
        .navigationBarTitleDisplayMode(.inline)
    }
}
