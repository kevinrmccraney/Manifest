//
//  BandedItemListView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import SwiftData

struct BandedItemListView: View {
    let items: [Item]
    let showAttachmentIcons: Bool
    let isShowingArchived: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var itemToDelete: Item?
    @State private var showingDeleteAlert = false
    @State private var deletingItems: Set<UUID> = [] // Track items being deleted
    
    var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                // Only show item if it's not being deleted
                if !deletingItems.contains(item.id) {
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        BandedItemRowView(
                            item: item,
                            isEvenRow: index % 2 == 0,
                            showAttachmentIcons: showAttachmentIcons
                        )
                    }
                    .listRowInsets(EdgeInsets()) // Remove default list row padding
                    .listRowSeparator(.hidden) // Hide default separators since we have banded rows
                    .buttonStyle(PlainButtonStyle()) // Remove the disclosure indicator/chevron
                    .onTapGesture {
                        // Record view when item is tapped in list
                        item.recordView()
                    }
                    .swipeActions(edge: .trailing) {
                        // Delete action on left swipe
                        Button("Delete", role: .destructive) {
                            // Immediately hide the item with animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                deletingItems.insert(item.id)
                            }
                            // Then show confirmation dialog
                            itemToDelete = item
                            showingDeleteAlert = true
                        }
                    }
                    .swipeActions(edge: .leading) {
                        // Archive action on right swipe
                        if isShowingArchived {
                            Button("Unarchive") {
                                withAnimation {
                                    item.unarchive()
                                }
                            }
                            .tint(.blue)
                        } else {
                            Button("Archive") {
                                withAnimation {
                                    item.archive()
                                }
                            }
                            .tint(.orange)
                        }
                    }
                    .contextMenu {
                        if isShowingArchived {
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
                        
                        Button("Delete", role: .destructive) {
                            itemToDelete = item
                            showingDeleteAlert = true
                        }
                    }
                }
            }
        }
        .listStyle(.plain) // Use plain list style to maintain custom appearance
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                // If cancelled, restore the item
                if let item = itemToDelete {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        deletingItems.remove(item.id)
                    }
                }
                itemToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete this item? This action cannot be undone.")
        }
    }
    
    private func deleteItem(_ item: Item) {
        // Actually delete from the model context
        modelContext.delete(item)
        
        // Clean up our tracking
        deletingItems.remove(item.id)
        itemToDelete = nil
        
        // Save the context to persist the deletion
        do {
            try modelContext.save()
        } catch {
            print("Error saving context after deletion: \(error)")
        }
    }
}
