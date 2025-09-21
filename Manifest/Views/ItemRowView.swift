//
//  BandedItemRowView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct BandedItemRowView: View, ItemDisplayable {
    let item: Item
    let isEvenRow: Bool
    let showAttachmentIcons: Bool
    let showItemDescriptions: Bool
    let frameHeight: CGFloat = 50
    
    var rowBackground: Color {
        isEvenRow ? AppTheme.evenRowBackground : AppTheme.oddRowBackground
    }
    
    var body: some View {
        HStack {
            // Pin indicator - positioned to the left of the thumbnail
            ItemDisplayComponents.makePinIndicator(for: item, size: .small)
                .padding(.trailing, 4)
            
            // Thumbnail
            ItemDisplayComponents.makeThumbnail(for: item, size: frameHeight)
            
            VStack(alignment: .leading, spacing: 4) {
                ItemDisplayComponents.makeTitle(for: item)
                
                ItemDisplayComponents.makeDescription(for: item, showItemDescriptions: showItemDescriptions, font: .subheadline, lineLimit: 1)
                
                // Tags
                ItemDisplayComponents.makeTags(for: item, maxTags: 3, style: .row)
            }
            
            Spacer()
            
            // File attachment and context badges indicator
            VStack(spacing: 4) {
                ItemDisplayComponents.makeAttachmentIndicator(for: item, showAttachmentIcons: showAttachmentIcons, style: .inline)
                
                // Context badges
                HStack(spacing: 2) {
                    if item.contextFlags.isFragile {
                        ContextBadgeView(type: .fragile, size: .small)
                    }
                    if item.contextFlags.isHeavy {
                        ContextBadgeView(type: .heavy, size: .small)
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
