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
    @State private var itemToEdit: Item?
    @State private var showingEditSheet = false
    @State private var navigationCoordinator = NavigationCoordinator.shared
    
    var body: some View {
        List {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                // Only show item if it's not being deleted
                if !deletingItems.contains(item.id) {
                    BandedItemRowView(
                        item: item,
                        isEvenRow: index % 2 == 0,
                        showAttachmentIcons: showAttachmentIcons
                    )
                    .listRowInsets(EdgeInsets()) // Remove default list row padding
                    .listRowSeparator(.hidden) // Hide default separators since we have banded rows
                    .contentShape(Rectangle()) // Make entire row tappable
                    .onTapGesture {
                        // Navigate to detail view
                        navigationCoordinator.navigateToItem(item)
                    }
                    .swipeActions(edge: .trailing) {
                        // Details action on left swipe (moved here)
                        Button("Details") {
                            item.recordView() // Record view when accessing via swipe
                            navigationCoordinator.navigateToItem(item)
                        }
                        .tint(.blue)
                        
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
                            .tint(.orange)
                        } else {
                            Button("Archive") {
                                withAnimation {
                                    item.archive()
                                }
                            }
                            .tint(.orange)
                        }
                    }
                    .onLongPressGesture {
                        // Add haptic feedback for long press
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        // Show context menu actions via alert
                        showLongPressActions(for: item)
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
        // Details option
        Button("Details") {
            item.recordView()
            navigationCoordinator.navigateToItem(item)
        }
        
        // Only show Edit button if item is not archived
        if !item.isArchived {
            Button("Edit") {
                itemToEdit = item
                showingEditSheet = true
            }
        }
        
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
    
    private func showLongPressActions(for item: Item) {
        // Create an action sheet for long press
        let alert = UIAlertController(title: item.name, message: "Choose an action", preferredStyle: .actionSheet)
        
        // Details action
        alert.addAction(UIAlertAction(title: "View Details", style: .default) { _ in
            item.recordView()
            navigationCoordinator.navigateToItem(item)
        })
        
        // Edit action (only if not archived)
        if !item.isArchived {
            alert.addAction(UIAlertAction(title: "Edit", style: .default) { _ in
                itemToEdit = item
                showingEditSheet = true
            })
        }
        
        // Archive/Unarchive action
        if isShowingArchived {
            alert.addAction(UIAlertAction(title: "Unarchive", style: .default) { _ in
                withAnimation {
                    item.unarchive()
                }
            })
        } else {
            alert.addAction(UIAlertAction(title: "Archive", style: .default) { _ in
                withAnimation {
                    item.archive()
                }
            })
        }
        
        // Delete action
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            itemToDelete = item
            showingDeleteAlert = true
        })
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
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
