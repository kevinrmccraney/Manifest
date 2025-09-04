//
//  ItemDetailView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ItemDetailView: View {
    @Bindable var item: Item
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Large image
                ImageDisplaySection(item: item)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title and description
                    TitleDescriptionSection(item: item)
                    
                    // Tags
                    if !item.tags.isEmpty {
                        TagsDisplayView(tags: item.tags)
                    }
                    
                    // File attachments - both new and legacy
                    if item.hasAnyAttachment {
                        MultiAttachmentsDisplayView(item: item)
                    }
                    
                    // Custom fields
                    let customFields = item.customFieldsDict
                    if !customFields.isEmpty {
                        CustomFieldsDisplayView(customFields: customFields)
                    }
                    
                    // Timestamps
                    TimestampSection(item: item)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditItemView(item: item)
        }
    }
}
