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
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        BandedItemRowView(
                            item: item,
                            isEvenRow: index % 2 == 0,
                            showAttachmentIcons: showAttachmentIcons
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    .swipeActions(edge: .trailing) {
                        // Delete action (secondary)
                        Button("Delete", role: .destructive) {
                            itemToDelete = item
                            showingDeleteAlert = true
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        // Archive action (primary)
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
                }
            }
            .padding(.horizontal, 0) // Remove horizontal padding to extend banding to edges
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
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
        withAnimation {
            modelContext.delete(item)
        }
        itemToDelete = nil
    }
}
