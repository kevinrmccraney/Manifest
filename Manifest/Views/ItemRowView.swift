//
//  BandedItemRowView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct BandedItemRowView: View {
    let item: Item
    let isEvenRow: Bool
    let showAttachmentIcons: Bool
    
    var rowBackground: Color {
        isEvenRow ? AppTheme.evenRowBackground : AppTheme.oddRowBackground
    }
    
    var body: some View {
        HStack {
            // Thumbnail
            if let image = item.thumbnailImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(item.effectiveEmojiPlaceholder)
                            .font(.system(size: 20))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if !item.itemDescription.isEmpty {
                    Text(item.itemDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Tags
                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(item.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            if item.tags.count > 3 {
                                Text("+\(item.tags.count - 3)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // File attachment indicator with count - only show if setting is enabled
            if item.hasAnyAttachment && showAttachmentIcons {
                HStack(spacing: 2) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    let totalAttachments = item.attachments.count + (item.attachmentData != nil ? 1 : 0)
                    if totalAttachments > 1 {
                        Text("\(totalAttachments)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(rowBackground)
        .contentShape(Rectangle()) // Make entire row tappable
    }
}
