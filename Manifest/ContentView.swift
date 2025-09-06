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
    @Query private var allItems: [Item]
    
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
    @State private var showingSortPicker = false
    
    // Use settings for initial view mode and sort
    @State private var showingGridView = AppSettings.shared.defaultViewMode == .grid
    @State private var enabledNFCScanning = AppSettings.shared.enableNFC
    @State private var enabledQRScanning = AppSettings.shared.enableQR
    @State private var showViewToggle = AppSettings.shared.showViewToggle
    @State private var showSortPicker = AppSettings.shared.showSortPicker
    @State private var showAttachmentIcons = AppSettings.shared.showAttachmentIcons
    @State private var currentSortOption = AppSettings.shared.currentSortOption
    
    // Initialize the query with default sort
    init() {
        let sortOption = AppSettings.shared.currentSortOption
        let sortDescriptors = Self.sortDescriptors(for: sortOption)
        _allItems = Query(sort: sortDescriptors)
    }
    
    // Filter items based on archive status
    var activeItems: [Item] {
        let filtered = allItems.filter { !$0.isArchived }
        return applySorting(to: filtered)
    }
    
    var archivedItems: [Item] {
        let filtered = allItems.filter { $0.isArchived }
        return applySorting(to: filtered)
    }
    
    var currentItems: [Item] {
        showArchivedItems ? archivedItems : activeItems
    }
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return currentItems
        } else {
            let filtered = currentItems.filter { item in
                item.name.localizedCaseInsensitiveContains(searchText) ||
                item.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                item.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
            return filtered
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Archive toggle section
                if !archivedItems.isEmpty && !showingSearch {
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
                
                // Show search bar inline when active (not as overlay)
                if showingSearch {
                    HStack(spacing: 12) {
                        SearchBar(text: $searchText)
                        
                        Button("Cancel") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSearch = false
                                searchText = ""
                            }
                        }
                        .foregroundStyle(.blue)
                        .fontWeight(.medium)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryBackground)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
            .background(AppTheme.primaryBackground)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !showingSearch {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape")
                        }
                        
                        if !currentItems.isEmpty && showViewToggle {
                            Button(action: toggleViewMode) {
                                Image(systemName: showingGridView ? "list.bullet" : "square.grid.2x2")
                            }
                        }
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !currentItems.isEmpty && !showingSearch {
                        // Sort button
                        if showSortPicker {
                            Button(action: { showingSortPicker = true }) {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                        }
                        
                        Button(action: toggleSearch) {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                }
            }
            .navigationTitle(showingSearch ? "" : (showArchivedItems ? "Archived Items" : "Items"))
            .navigationBarTitleDisplayMode(showingSearch ? .inline : .large)
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
            .confirmationDialog("Sort Items", isPresented: $showingSortPicker, titleVisibility: .visible) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(option.displayName) {
                        updateSortOption(option)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Choose how to sort your items")
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
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
        .onOpenURL { url in
            handleDeepLink(url: url)
        }
    }
    
    // MARK: - Sort Functions
    
    static func sortDescriptors(for option: SortOption) -> [SortDescriptor<Item>] {
        switch option {
        case .nameAscending:
            return [SortDescriptor(\Item.name, order: .forward)]
        case .nameDescending:
            return [SortDescriptor(\Item.name, order: .reverse)]
        case .newestFirst:
            return [SortDescriptor(\Item.createdAt, order: .reverse)]
        case .oldestFirst:
            return [SortDescriptor(\Item.createdAt, order: .forward)]
        case .recentlyModified:
            return [SortDescriptor(\Item.updatedAt, order: .reverse)]
        case .oldestModified:
            return [SortDescriptor(\Item.updatedAt, order: .forward)]
        case .recentlyViewed:
            return [SortDescriptor(\Item.lastViewedAt, order: .reverse)]
        case .frequentlyViewed:
            return [SortDescriptor(\Item.viewCount, order: .reverse)]
        }
    }
    
    private func applySorting(to items: [Item]) -> [Item] {
        switch currentSortOption {
        case .nameAscending:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .newestFirst:
            return items.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return items.sorted { $0.createdAt < $1.createdAt }
        case .recentlyModified:
            return items.sorted { $0.updatedAt > $1.updatedAt }
        case .oldestModified:
            return items.sorted { $0.updatedAt < $1.updatedAt }
        case .recentlyViewed:
            return items.sorted { (item1, item2) in
                let date1 = item1.lastViewedAt ?? Date.distantPast
                let date2 = item2.lastViewedAt ?? Date.distantPast
                return date1 > date2
            }
        case .frequentlyViewed:
            return items.sorted { $0.viewCount > $1.viewCount }
        }
    }
    
    private func updateSortOption(_ option: SortOption) {
        currentSortOption = option
        settings.currentSortOption = option
    }
    
    // MARK: - Other Functions
    
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
            // Record the view when accessed via NFC
            item.recordView()
            navigationCoordinator.navigateToItem(item)
        } else {
            showingNFCItemNotFound = true
        }
    }
    
    private func handleQRScan(itemID: UUID) {
        // Find the item with the scanned ID (including archived items)
        if let item = allItems.first(where: { $0.id == itemID }) {
            // Record the view when accessed via QR
            item.recordView()
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
