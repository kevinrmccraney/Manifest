//
//  ItemDisplayable.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-21.
//


//
//  ItemDisplayView.swift
//  Manifest
//
//  Unified item display components
//

import SwiftUI

// MARK: - Protocol

protocol ItemDisplayable {
    var item: Item { get }
    var showAttachmentIcons: Bool { get }
    var showItemDescriptions: Bool { get }
}

// MARK: - Base Components

struct ItemDisplayComponents {
    
    // MARK: - Thumbnail Component
    
    @ViewBuilder
    static func makeThumbnail(for item: Item, size: CGFloat, cornerRadius: CGFloat = 8) -> some View {
        if let image = item.thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
                .cornerRadius(cornerRadius)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.1))
                .frame(width: size, height: size)
                .overlay(
                    Text(item.effectiveEmojiPlaceholder)
                        .font(.system(size: size * 0.6))
                )
        }
    }
    
    // MARK: - Pin Indicator
    
    @ViewBuilder
    static func makePinIndicator(for item: Item, size: PinSize = .medium) -> some View {
        if item.isPinned {
            Image(systemName: "pin.fill")
                .font(size.font)
                .foregroundStyle(.white)
                .padding(size.padding)
                .background(Color.blue)
                .clipShape(Circle())
                .rotationEffect(.degrees(45))
        }
    }
    
    enum PinSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            case .large: return 6
            }
        }
    }
    
    // MARK: - Attachment Indicator
    
    @ViewBuilder
    static func makeAttachmentIndicator(for item: Item, showAttachmentIcons: Bool, style: AttachmentStyle = .overlay) -> some View {
        if item.hasAnyAttachment && showAttachmentIcons {
            let totalAttachments = item.attachments.count + (item.attachmentData != nil ? 1 : 0)
            
            HStack(spacing: 2) {
                Image(systemName: "doc.fill")
                    .foregroundStyle(style.foregroundColor)
                    .font(.caption)
                
                if totalAttachments > 1 {
                    Text("\(totalAttachments)")
                        .font(.caption2)
                        .foregroundStyle(style.foregroundColor)
                }
            }
            .padding(4)
            .background(style.backgroundColor)
            .cornerRadius(4)
        }
    }
    
    enum AttachmentStyle {
        case overlay, inline
        
        var foregroundColor: Color {
            switch self {
            case .overlay: return .white
            case .inline: return .secondary
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .overlay: return Color.black.opacity(0.6)
            case .inline: return .clear
            }
        }
    }
    
    // MARK: - Context Badges
    
    @ViewBuilder
    static func makeContextBadges(for item: Item) -> some View {
        if item.contextFlags.hasAnyFlags {
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
    
    // MARK: - Tags Display
    
    @ViewBuilder
    static func makeTags(for item: Item, maxTags: Int = 3, style: TagStyle = .row) -> some View {
        if !item.tags.isEmpty {
            switch style {
            case .row:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(item.tags.prefix(maxTags), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundStyle(.blue)
                                .cornerRadius(4)
                        }
                        if item.tags.count > maxTags {
                            Text("+\(item.tags.count - maxTags)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            case .grid:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 4) {
                    ForEach(item.tags.prefix(maxTags), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .cornerRadius(3)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    enum TagStyle {
        case row, grid
    }
    
    // MARK: - Item Title
    
    @ViewBuilder
    static func makeTitle(for item: Item, font: Font = .headline, lineLimit: Int = 1) -> some View {
        Text(item.name)
            .font(font)
            .lineLimit(lineLimit)
            .foregroundStyle(.primary)
    }
    
    // MARK: - Item Description
    
    @ViewBuilder
    static func makeDescription(for item: Item, showItemDescriptions: Bool, font: Font = .subheadline, lineLimit: Int = 2) -> some View {
        if !item.itemDescription.isEmpty && showItemDescriptions {
            Text(item.itemDescription)
                .font(font)
                .foregroundStyle(.secondary)
                .lineLimit(lineLimit)
        }
    }
}