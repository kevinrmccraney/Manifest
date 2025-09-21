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
    let showItemDescriptions: Bool
    let isShowingArchived: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var itemToDelete: Item?
    @State private var showingDeleteAlert = false
    @State private var deletingItems: Set<UUID> = [] // Track items being deleted
    @State private var itemToEdit: Item?
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                // Only show item if it's not being deleted
                if !deletingItems.contains(item.id) {
                    ZStack {
                        // The row content
                        UnifiedItemCard(
                            item: item,
                            displayStyle: .listRow(isEven: index % 2 == 0),
                            showAttachmentIcons: showAttachmentIcons,
                            showItemDescriptions: showItemDescriptions,
                            contextualData: UnifiedItemCard.ContextualData(
                                isShowingArchived: isShowingArchived,
                                onEdit: {
                                    itemToEdit = item
                                    showingEditSheet = true
                                },
                                onDelete: {
                                    itemToDelete = item
                                    showingDeleteAlert = true
                                },
                                onTogglePin: {
                                    withAnimation {
                                        item.togglePin()
                                    }
                                },
                                onToggleArchive: {
                                    withAnimation {
                                        item.toggleArchive()
                                    }
                                }
                            )
                        )                        // Invisible NavigationLink overlay
                        NavigationLink(destination: ItemDetailView(item: item)) {
                            EmptyView()
                        }
                        .opacity(0)
                        .simultaneousGesture(TapGesture().onEnded {
                            item.recordView()
                        })
                    }
                    .listRowInsets(EdgeInsets()) // Remove default list row padding
                    .listRowSeparator(.hidden) // Hide default separators since we have banded rows
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
                        // Pin/Unpin action on right swipe
                        Button(item.isPinned ? "Unpin" : "Pin") {
                            withAnimation {
                                item.togglePin()
                            }
                        }
                        .tint(item.isPinned ? .gray : .purple)
                        
                        // Archive action on right swipe
                        Button(isShowingArchived ? "Unarchive" : "Archive") {
                            withAnimation {
                                item.toggleArchive()
                            }
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        contextMenuItems(for: item)
                    }
                }
            }
        }
        .listStyle(.plain) // Use plain list style to maintain custom appearance
        .sheet(isPresented: $showingEditSheet) {
            if let item = itemToEdit {
                AddEditItemView(item: item)
            }
        }
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
    
    @ViewBuilder
    private func contextMenuItems(for item: Item) -> some View {
        // Pin/Unpin option
        Button(item.isPinned ? "Unpin" : "Pin") {
            withAnimation {
                item.togglePin()
            }
        }
        
        // Only show Edit button if item is not archived
        if !item.isArchived {
            Button("Edit") {
                itemToEdit = item
                showingEditSheet = true
            }
        }
        
        Button(isShowingArchived ? "Unarchive" : "Archive") {
            withAnimation {
                item.toggleArchive()
            }
        }
        
        Button("Delete", role: .destructive) {
            itemToDelete = item
            showingDeleteAlert = true
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
