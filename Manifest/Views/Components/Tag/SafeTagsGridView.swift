//
//  SafeTagsGridView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SafeTagsGridView: View {
    @Binding var tags: [String]
    @State private var tagsCopy: [String] = []
    
    var body: some View {
        VStack {
            if !tagsCopy.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(Array(tagsCopy.enumerated()), id: \.offset) { index, tag in
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
        .onAppear {
            tagsCopy = tags
        }
        .onChange(of: tags) { _, newValue in
            tagsCopy = newValue
        }
    }
    
    private func removeTag(at index: Int) {
        guard index < tagsCopy.count && index >= 0 else { return }
        tagsCopy.remove(at: index)
        tags = tagsCopy // Update the binding
    }
}
