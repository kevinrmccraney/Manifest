//
//  SafeTagsGridView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SafeTagsGridView: View {
    @Binding var tags: [String]
    
    var body: some View {
        VStack {
            if !tags.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(Array(tags.enumerated()), id: \.element) { index, tag in
                        TagItemView(tag: tag) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                removeTag(at: index)
                            }
                        }
                    }
                }
            } else {
                Text("No tags added")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }
    
    private func removeTag(at index: Int) {
        guard index >= 0 && index < tags.count else { return }
        tags.remove(at: index)
    }
}
