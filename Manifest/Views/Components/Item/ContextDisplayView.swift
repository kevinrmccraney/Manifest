//
//  ContextDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//


//
//  ContextDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//

import SwiftUI

struct ContextDisplayView: View {
    let contextFlags: ItemContextFlags
    
    var body: some View {
        if contextFlags.hasAnyFlags {
            VStack(alignment: .leading, spacing: 8) {
                Text("Special Handling")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 6) {
                    if contextFlags.isFragile {
                        HStack {
                            ContextBadgeView(type: .fragile, size: .medium)
                            Text("Fragile - Handle with care")
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                    
                    if contextFlags.isHeavy {
                        HStack {
                            ContextBadgeView(type: .heavy, size: .medium)
                            Text("Heavy - Use caution when lifting")
                                .font(.subheadline)
                            Spacer()
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
}
