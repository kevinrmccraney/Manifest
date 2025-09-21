//
//  ThemedGridItemView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ThemedGridItemView: View, ItemDisplayable {
    let item: Item
    let showAttachmentIcons: Bool
    let showItemDescriptions: Bool
    let frameHeight: CGFloat = 120
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail - fixed height
            ZStack(alignment: .topTrailing) {
                ItemDisplayComponents.makeThumbnail(for: item, size: frameHeight, cornerRadius: 12)
                    .frame(height: frameHeight)
                
                // Overlay container with pin at top left, file icon at top right, context badges at bottom right
                VStack {
                    // Top row: Pin indicator and file attachment icon
                    HStack {
                        ItemDisplayComponents.makePinIndicator(for: item, size: .medium)
                        
                        Spacer()
                        
                        ItemDisplayComponents.makeAttachmentIndicator(for: item, showAttachmentIcons: showAttachmentIcons, style: .overlay)
                    }
                    
                    Spacer()
                    
                    // Bottom row: Context badges only
                    HStack {
                        Spacer()
                        ItemDisplayComponents.makeContextBadges(for: item)
                    }
                }
                .padding(8)
            }
            
            // Content area - fixed height container
            VStack(alignment: .leading, spacing: 4) {
                // Title - always present, fixed height
                ItemDisplayComponents.makeTitle(for: item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 20) // Fixed height for title
                
                // Description area - fixed height whether empty or not
                Group {
                    if showItemDescriptions {
                        ItemDisplayComponents.makeDescription(for: item, showItemDescriptions: showItemDescriptions, font: .caption, lineLimit: 2)
                    } else {
                        Text("")
                            .font(.caption)
                            .opacity(0) // Invisible but takes up space
                    }
                }
                .frame(height: showItemDescriptions ? 28 : 0) // Adjust height based on setting
                
                // Tags area - fixed height whether empty or not
                Group {
                    ItemDisplayComponents.makeTags(for: item, maxTags: 2, style: .row)
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
