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
        VStack(alignment: .leading, spacing: 8) {
            Text("Info")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Created:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                
                if item.updatedAt != item.createdAt {
                    HStack {
                        Text("Modified:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.updatedAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
                
                if debugMode {
                    if let lastViewed = item.lastViewedAt {
                        HStack {
                            Text("Last Viewed:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(lastViewed.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    HStack {
                        Text("View Count:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(item.viewCount)")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}
