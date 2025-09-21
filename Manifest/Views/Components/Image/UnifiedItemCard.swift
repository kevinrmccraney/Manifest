//
//  UnifiedItemCard.swift
//  Manifest
//
//  Single item display component for all contexts
//

import SwiftUI

struct UnifiedItemCard: View {
    let item: Item
    let displayStyle: DisplayStyle
    let showAttachmentIcons: Bool
    let showItemDescriptions: Bool
    let contextualData: ContextualData?
    
    enum DisplayStyle: Equatable {
        case grid
        case listRow(isEven: Bool)
        case compact
    }
    
    struct ContextualData {
        let isShowingArchived: Bool
        let onEdit: (() -> Void)?
        let onDelete: (() -> Void)?
        let onTogglePin: (() -> Void)?
        let onToggleArchive: (() -> Void)?
    }
    
    var body: some View {
        switch displayStyle {
        case .grid:
            gridCard
        case .listRow(let isEven):
            listRowCard(isEven: isEven)
        case .compact:
            compactCard
        }
    }
    
    // MARK: - Grid Card
    
    private var gridCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            thumbnailWithOverlays(size: 120, cornerRadius: 12)
                .frame(height: 120)
            
            contentArea(titleFont: .headline, descriptionFont: .caption, maxHeight: 68)
        }
        .frame(height: 196)
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.cardShadow, radius: 2, x: 0, y: 1)
    }
    
    // MARK: - List Row Card
    
    private func listRowCard(isEven: Bool) -> some View {
        HStack {
            ItemDisplayComponents.makePinIndicator(for: item, size: .small)
                .padding(.trailing, 4)
            
            thumbnailWithOverlays(size: 50)
            
            contentArea(titleFont: .headline, descriptionFont: .subheadline, maxHeight: nil)
            
            Spacer()
            
            trailingIcons
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isEven ? AppTheme.evenRowBackground : AppTheme.oddRowBackground)
        .contentShape(Rectangle())
    }
    
    // MARK: - Compact Card
    
    private var compactCard: some View {
        HStack(spacing: 12) {
            thumbnailWithOverlays(size: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                ItemDisplayComponents.makeTitle(for: item, font: .subheadline)
                if showItemDescriptions {
                    ItemDisplayComponents.makeDescription(
                        for: item,
                        showItemDescriptions: showItemDescriptions,
                        font: .caption,
                        lineLimit: 1
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    // MARK: - Reusable Components
    
    private func thumbnailWithOverlays(size: CGFloat, cornerRadius: CGFloat = 8) -> some View {
        ZStack(alignment: .topTrailing) {
            ItemDisplayComponents.makeThumbnail(for: item, size: size, cornerRadius: cornerRadius)
            
            if displayStyle == .grid {
                gridOverlays
            }
        }
    }
    
    private var gridOverlays: some View {
        VStack {
            HStack {
                ItemDisplayComponents.makePinIndicator(for: item, size: .medium)
                Spacer()
                ItemDisplayComponents.makeAttachmentIndicator(
                    for: item,
                    showAttachmentIcons: showAttachmentIcons,
                    style: .overlay
                )
            }
            
            Spacer()
            
            HStack {
                Spacer()
                ItemDisplayComponents.makeContextBadges(for: item)
            }
        }
        .padding(8)
    }
    
    private func contentArea(titleFont: Font, descriptionFont: Font, maxHeight: CGFloat?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ItemDisplayComponents.makeTitle(for: item, font: titleFont)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if showItemDescriptions {
                ItemDisplayComponents.makeDescription(
                    for: item,
                    showItemDescriptions: showItemDescriptions,
                    font: descriptionFont,
                    lineLimit: displayStyle == .grid ? 2 : 1
                )
            }
            
            ItemDisplayComponents.makeTags(for: item, maxTags: displayStyle == .grid ? 2 : 3, style: .row)
        }
        .frame(maxHeight: maxHeight)
    }
    
    private var trailingIcons: some View {
        VStack(spacing: 4) {
            ItemDisplayComponents.makeAttachmentIndicator(
                for: item,
                showAttachmentIcons: showAttachmentIcons,
                style: .inline
            )
            
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
}
