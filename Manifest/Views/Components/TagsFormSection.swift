//
//  TagsFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct TagsFormSection: View {
    @Binding var tags: [String]
    @Binding var newTag: String
    
    var body: some View {
        Section(header: Text("Tags")) {
            HStack {
                TextField("Add tag", text: $newTag)
                    .onSubmit {
                        addTag()
                    }
                
                Button("Add") {
                    addTag()
                }
                .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            SafeTagsGridView(tags: $tags)
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
}
