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
    @State private var showingQRScanner = false
    @State private var searchText = ""
    @State private var settings = AppSettings.shared
    @State private var showingNFCItemNotFound = false
    @State private var showingQRItemNotFound = false
    @State private var navigationCoordinator = NavigationCoordinator.shared
    @State private var showArchivedItems = false
    
    // Use settings for initial view mode
    @State private var showingGridView = AppSettings.shared.defaultViewMode == .grid
    @State private var enabledNFCScanning = AppSettings.shared.enableNFC
    @State private var enabledQRScanning = AppSettings.shared.enableQR
    @State private var showViewToggle = AppSettings.shared.showViewToggle
    @State private var showAttachmentIcons = AppSettings.shared.showAttachmentIcons
    
    // Filter items based on archive status
    var activeItems: [Item] {
        allItems.filter { !$0.isArchived }
    }
    
    var archivedItems: [Item] {
        allItems.filter { $0.isArchived }
    }
    
    var currentItems: [Item] {
        showArchivedItems ? archivedItems : activeItems
    }
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return currentItems
        } else {
            return currentItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Archive toggle section
                if !archivedItems.isEmpty {
                    HStack {
                        Button(action: {
                            withAnimation {
                                showArchivedItems.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: showArchivedItems ? "tray.full" : "tray")
                                Text(showArchivedItems ? "Archived Items (\(archivedItems.count))" : "Show Archived (\(archivedItems.count))")
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .rotationEffect(.degrees(showArchivedItems ? 90 : 0))
                                    .animation(.easeInOut(duration: 0.2), value: showArchivedItems)
                            }
                        }
                        .foregroundStyle(showArchivedItems ? .orange : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppTheme.primaryBackground)
                    }
                    .background(AppTheme.primaryBackground)
                }
                
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
                } else if currentItems.isEmpty {
                    if showArchivedItems {
                        // Empty archived state
                        VStack(spacing: 20) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundStyle(.gray)
                            
                            Text("No Archived Items")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Items you archive will appear here")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Back to All Items") {
                                withAnimation {
                                    showArchivedItems = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.secondaryBackground)
                    } else {
                        EmptyStateView(showingAddItem: $showingAddItem)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(AppTheme.secondaryBackground)
                    }
                } else {
                    if showingGridView {
                        GridView(
                            items: filteredItems,
                            showAttachmentIcons: showAttachmentIcons,
                            isShowingArchived: showArchivedItems
                        )
                        .background(AppTheme.secondaryBackground)
                    } else {
                        BandedItemListView(
                            items: filteredItems,
                            showAttachmentIcons: settings.showAttachmentIcons,
                            isShowingArchived: showArchivedItems
                        )
                        .background(AppTheme.secondaryBackground)
                    }
                }
            }
            .background(AppTheme.primaryBackground) // Top area white/black
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    
                    if !currentItems.isEmpty {
                        
                        if showViewToggle{
                            
                            Button(action: toggleViewMode) {
                                Image(systemName: showingGridView ? "list.bullet" : "square.grid.2x2")
                            }
                        }
                    }
                    
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    if !currentItems.isEmpty {
                        Button(action: toggleSearch) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    
                }
            }
            .navigationTitle(showArchivedItems ? "Archived Items" : "Items")
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
            .sheet(isPresented: $showingQRScanner) {
                QRScannerView { itemID in
                    handleQRScan(itemID: itemID)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if enabledNFCScanning {
                        Button(action: { showingNFCScanner = true }) {
                            Image(systemName: "wave.3.right")
                        }
                    }
                    
                    if enabledQRScanning {
                        Button(action: { showingQRScanner = true }) {
                            Image(systemName: "qrcode.viewfinder")
                        }
                    }
                    
                    // Only show add button when not viewing archived items
                    if !showArchivedItems {
                        Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .alert("Item Not Found", isPresented: $showingNFCItemNotFound) {
                Button("OK") { }
            } message: {
                Text("The scanned NFC tag contains an item ID that doesn't exist in your Manifest. The item may have been deleted or belongs to a different user.")
            }
            .alert("Item Not Found", isPresented: $showingQRItemNotFound) {
                Button("OK") { }
            } message: {
                Text("The scanned QR code contains an item ID that doesn't exist in your Manifest. The item may have been deleted or belongs to a different user.")
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
        // Find the item with the scanned ID (including archived items)
        if let item = allItems.first(where: { $0.id == itemID }) {
            navigationCoordinator.navigateToItem(item)
        } else {
            showingNFCItemNotFound = true
        }
    }
    
    private func handleQRScan(itemID: UUID) {
        // Find the item with the scanned ID (including archived items)
        if let item = allItems.first(where: { $0.id == itemID }) {
            navigationCoordinator.navigateToItem(item)
        } else {
            showingQRItemNotFound = true
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
                    handleNFCScan(itemID: itemID) // Reuse the same logic
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
