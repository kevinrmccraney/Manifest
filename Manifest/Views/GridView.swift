//
//  GridView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import SwiftData

struct GridView: View {
    let items: [Item]
    let showAttachmentIcons: Bool
    let showItemDescriptions: Bool
    let isShowingArchived: Bool
    @Environment(\.modelContext) private var modelContext
    @State private var itemToDelete: Item?
    @State private var showingDeleteAlert = false
    @State private var itemForActionSheet: Item?
    @State private var showingItemActionSheet = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items, id: \.id) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ThemedGridItemView(item: item, showAttachmentIcons: showAttachmentIcons, showItemDescriptions: showItemDescriptions)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        item.recordView()
                    })
                    .onLongPressGesture {
                        itemForActionSheet = item
                        showingItemActionSheet = true
                    }
                    .contextMenu {
                        contextMenuItems(for: item)
                    }
                }
            }
            .padding()
        }
        .confirmationDialog("Item Actions", isPresented: $showingItemActionSheet) {
            if let item = itemForActionSheet {
                // Pin/Unpin option
                Button(item.isPinned ? "Unpin" : "Pin") {
                    withAnimation {
                        item.togglePin()
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
                
                Button("Cancel", role: .cancel) { }
            }
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
    
    @ViewBuilder
    private func contextMenuItems(for item: Item) -> some View {
        // Pin/Unpin option
        Button(item.isPinned ? "Unpin" : "Pin") {
            withAnimation {
                item.togglePin()
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
    
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
        itemToDelete = nil
        itemForActionSheet = nil
    }
}
