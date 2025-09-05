//
//  ContentView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.createdAt, order: .reverse) private var allItems: [Item]
    
    @State private var showingAddItem = false
    @State private var showingSearch = false
    @State private var showingSettings = false
    @State private var showingNFCScanner = false
    @State private var searchText = ""
    @State private var settings = AppSettings.shared
    @State private var showingNFCItemNotFound = false
    @State private var navigationCoordinator = NavigationCoordinator.shared
    
    // Use settings for initial view mode
    @State private var showingGridView = AppSettings.shared.defaultViewMode == .grid
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return allItems
        } else {
            return allItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingSearch {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .background(AppTheme.primaryBackground) // White/Black background for search area
                }
                
                if filteredItems.isEmpty && !searchText.isEmpty {
                    SearchEmptyView(searchText: searchText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.secondaryBackground)
                } else if allItems.isEmpty {
                    EmptyStateView(showingAddItem: $showingAddItem)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.secondaryBackground)
                } else {
                    if showingGridView {
                        GridView(items: filteredItems, showAttachmentIcons: settings.showAttachmentIcons)
                            .background(AppTheme.secondaryBackground)
                    } else {
                        BandedItemListView(items: filteredItems, showAttachmentIcons: settings.showAttachmentIcons)
                            .background(AppTheme.secondaryBackground)
                    }
                }
            }
            .background(AppTheme.primaryBackground) // Top area white/black
            .navigationTitle("Manifest")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    
                    if !allItems.isEmpty {
                        
                        Button(action: toggleViewMode) {
                            Image(systemName: showingGridView ? "list.bullet" : "square.grid.2x2")
                        }
                    }
                    
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // NFC Scanner button
                    Button(action: { showingNFCScanner = true }) {
                        Image(systemName: "wave.3.right")
                    }
                    
                    if !allItems.isEmpty {
                        Button(action: toggleSearch) {
                            Image(systemName: "magnifyingglass")
                        }
                        
                    }
                    
                    
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddEditItemView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingNFCScanner) {
                NFCScannerView { itemID in
                    handleNFCScan(itemID: itemID)
                }
            }
            .alert("Item Not Found", isPresented: $showingNFCItemNotFound) {
                Button("OK") { }
            } message: {
                Text("The scanned NFC tag contains an item ID that doesn't exist in your Manifest. The item may have been deleted or belongs to a different user.")
            }
            .sheet(isPresented: $navigationCoordinator.showingItemDetail) {
                if let item = navigationCoordinator.selectedItem {
                    NavigationView {
                        ItemDetailView(item: item)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        navigationCoordinator.clearSelection()
                                    }
                                }
                            }
                    }
                }
            }
        }
        .background(AppTheme.secondaryBackground.ignoresSafeArea()) // Overall grey background
        .onOpenURL { url in
            handleDeepLink(url: url)
        }
    }
    
    private func toggleViewMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingGridView.toggle()
        }
    }
    
    private func toggleSearch() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSearch.toggle()
            if !showingSearch {
                searchText = ""
            }
        }
    }
    
    private func handleNFCScan(itemID: UUID) {
        // Find the item with the scanned ID
        if let item = allItems.first(where: { $0.id == itemID }) {
            navigationCoordinator.navigateToItem(item)
        } else {
            showingNFCItemNotFound = true
        }
    }
    
    private func handleDeepLink(url: URL) {
        print("Received deep link: \(url)")
        
        // Handle manifest://item/{uuid} URLs
        if url.scheme == "manifest" && url.host == "item" {
            let pathComponents = url.pathComponents
            if pathComponents.count >= 2 {
                let uuidString = pathComponents[1]
                if let itemID = UUID(uuidString: uuidString) {
                    print("Parsed item ID from deep link: \(itemID)")
                    handleNFCScan(itemID: itemID)
                } else {
                    print("Invalid UUID in deep link: \(uuidString)")
                }
            } else {
                print("Invalid deep link format - missing UUID")
            }
        } else {
            print("Unhandled deep link scheme or host: \(url.scheme ?? "nil")://\(url.host ?? "nil")")
        }
    }
}
