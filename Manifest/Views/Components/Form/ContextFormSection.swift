//
//  ContextFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//

import SwiftUI

struct ContextFormSection: View {
    @Binding var contextFlags: ItemContextFlags
    @State private var showingContextOptions = false
    
    var body: some View {
        Section(header: Text("Item Context")) {
            DisclosureGroup(
                isExpanded: $showingContextOptions,
                content: {
                    VStack(spacing: 12) {
                        Toggle(isOn: $contextFlags.isFragile) {
                            HStack {
                                ContextBadgeView(type: .fragile, size: .medium)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Fragile")
                                        .font(.body)
                                    Text("Handle with care")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.vertical, 4)
                        
                        Toggle(isOn: $contextFlags.isHeavy) {
                            HStack {
                                ContextBadgeView(type: .heavy, size: .medium)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Heavy")
                                        .font(.body)
                                    Text("Use caution when lifting")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.vertical, 4)
                        
                        if contextFlags.hasAnyFlags {
                            HStack {
                                Text("Preview:")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                
                                HStack(spacing: 6) {
                                    if contextFlags.isFragile {
                                        ContextBadgeView(type: .fragile, size: .small)
                                    }
                                    if contextFlags.isHeavy {
                                        ContextBadgeView(type: .heavy, size: .small)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                },
                label: {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .frame(width: 24, height: 24)
                        
                        Text("Special Handling")
                        
                        Spacer()
                        
                        // Show active flags as small badges
                        if contextFlags.hasAnyFlags {
                            HStack(spacing: 4) {
                                if contextFlags.isFragile {
                                    ContextBadgeView(type: .fragile, size: .small)
                                }
                                if contextFlags.isHeavy {
                                    ContextBadgeView(type: .heavy, size: .small)
                                }
                            }
                        }
                    }
                }
            )
        }
    }
}

struct ContextBadgeView: View {
    let type: ContextBadgeType
    let size: BadgeSize
    
    enum BadgeSize {
        case small
        case medium
        case large
        
        var dimensions: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
    }
    
    var badgeColor: Color {
        switch type {
        case .fragile: return .red
        case .heavy: return .green
        }
    }
    
    var body: some View {
        Text(type.letter)
            .font(.system(size: size.fontSize, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: size.dimensions, height: size.dimensions)
            .background(badgeColor)
            .cornerRadius(4)
    }
}
