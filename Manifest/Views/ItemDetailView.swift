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
    @State private var showingActionSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Archive status banner
                if item.isArchived {
                    HStack {
                        Image(systemName: "archivebox.fill")
                        Text("This item is archived")
                        Spacer()
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.orange)
                    .cornerRadius(8)
                }
                
                // Large image
                ImageDisplaySection(item: item)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title and description
                    TitleDescriptionSection(item: item)
                    
                    // File attachments - both new and legacy
                    if item.hasAnyAttachment {
                        MultiAttachmentsDisplayView(item: item)
                    }
                    
                    // Tags
                    if !item.tags.isEmpty {
                        TagsDisplayView(tags: item.tags)
                    }
                    
                    // Custom fields
                    if !item.customFieldsDict.isEmpty {
                        CustomFieldsDisplayView(customFields: item.customFieldsDict)
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
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditItemView(item: item)
        }
        .confirmationDialog("Item Actions", isPresented: $showingActionSheet) {
            if item.isArchived {
                Button("Unarchive") {
                    withAnimation {
                        item.unarchive()
                    }
                }
            } else {
                Button("Archive") {
                    withAnimation {
                        item.archive()
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}
