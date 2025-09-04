//
//  TagsGridView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct TagsGridView: View {
    @Binding var tags: [String]
    
    var body: some View {
        if !tags.isEmpty {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                    TagItemView(tag: tag) {
                        removeTag(at: index)
                    }
                }
            }
        } else {
            Text("No tags added")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
    
    private func removeTag(at index: Int) {
        guard index < tags.count && index >= 0 else { return }
        tags.remove(at: index)
    }
}
