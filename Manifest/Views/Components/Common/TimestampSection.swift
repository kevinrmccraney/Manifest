//
//  TimestampSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct TimestampSection: View {
    let item: Item
    let debugMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Created \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundStyle(.tertiary)
            
            if item.updatedAt != item.createdAt {
                Text("Updated \(item.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.top, 8)
        if debugMode{
            VStack(alignment: .leading, spacing: 4) {
                Text("Open Count \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                if item.updatedAt != item.createdAt {
                    Text("lastOpenTime \(item.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.top, 8)
        }
    }
}
