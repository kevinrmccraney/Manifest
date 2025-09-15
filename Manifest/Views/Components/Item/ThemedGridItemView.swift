//
//  ThemedGridItemView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ThemedGridItemView: View {
    let item: Item
    let showAttachmentIcons: Bool
    let frameHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail - fixed height
            ZStack(alignment: .topTrailing) {
                if let image = item.thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: frameHeight)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: frameHeight)
                        .overlay(
                            Text(item.effectiveEmojiPlaceholder)
                                .font(.system(size: frameHeight * 0.9))
                        )
                }
                
                // Overlay container with pin at top left, file icon at top right, context badges at bottom right
                VStack {
                    // Top row: Pin indicator and file attachment icon
                    HStack {
                        if item.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .rotationEffect(.degrees(45))
                        }
                        
                        Spacer()
                        
                        // File attachment indicator at top right
                        if item.hasAnyAttachment && showAttachmentIcons {
                            HStack(spacing: 2) {
                                Image(systemName: "doc.fill")
                                    .foregroundStyle(.white)
                                    .font(.caption)
                                
                                let totalAttachments = item.attachments.count + (item.attachmentData != nil ? 1 : 0)
                                if totalAttachments > 1 {
                                    Text("\(totalAttachments)")
                                        .font(.caption2)
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(4)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                        }
                    }
                    
                    Spacer()
                    
                    // Bottom row: Context badges only
                    if item.contextFlags.hasAnyFlags {
                        HStack {
                            Spacer()
                            HStack(spacing: 2) {
                                if item.contextFlags.isFragile {
                                    ContextBadgeView(type: .fragile, size: .large)
                                }
                                if item.contextFlags.isHeavy {
                                    ContextBadgeView(type: .heavy, size: .large)
                                }
                            }
                        }
                    }
                }
                .padding(8)
            }
            
            // Content area - fixed height container
            VStack(alignment: .leading, spacing: 4) {
                // Title - always present, fixed height
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20) // Fixed height for title
                
                // Description area - fixed height whether empty or not
                Group {
                    if !item.itemDescription.isEmpty {
                        Text(item.itemDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("")
                            .font(.caption)
                            .opacity(0) // Invisible but takes up space
                    }
                }
                .frame(height: 28) // Fixed height for 2 lines of caption text
                
                // Tags area - fixed height whether empty or not
                Group {
                    if !item.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 2) {
                                ForEach(item.tags.prefix(2), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(3)
                                }
                            }
                        }
                    } else {
                        HStack { } // Empty HStack to maintain spacing
                    }
                }
                .frame(height: 16) // Fixed height for tags area
            }
            .frame(height: 68) // Fixed total height for content area (20 + 28 + 16 + spacing)
        }
        .frame(height: 196) // Fixed total card height (120 + 68 + spacing)
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 2, x: 0, y: 1)
    }
}
