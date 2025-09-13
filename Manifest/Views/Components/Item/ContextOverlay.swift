//
//  ContextOverlay.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//


//
//  ContextOverlay.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//

import SwiftUI

struct ContextOverlay: View {
    let contextFlags: ItemContextFlags
    let showAttachmentIcons: Bool
    let attachmentCount: Int
    
    var body: some View {
        HStack(spacing: 4) {
            // Context badges (fragile, heavy, etc.)
            if contextFlags.hasAnyFlags {
                HStack(spacing: 2) {
                    if contextFlags.isFragile {
                        ContextBadgeView(type: .fragile, size: .large)
                    }
                    if contextFlags.isHeavy {
                        ContextBadgeView(type: .heavy, size: .large)
                    }
                }
            }
            
            // File attachment indicator (existing functionality)
            if attachmentCount > 0 && showAttachmentIcons {
                HStack(spacing: 2) {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(.white)
                        .font(.caption)
                    
                    if attachmentCount > 1 {
                        Text("\(attachmentCount)")
                            .font(.caption2)
                            .foregroundStyle(.white)
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
            }
        }
    }
}