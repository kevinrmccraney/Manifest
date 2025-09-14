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
    @State private var showingNFCItemNotFound = false
    @State private var showingQRItemNotFound = false
    @State private var showArchivedItems = false
    @State private var showingSortPicker = false
    
    @State private var settingsRefreshId = UUID()
    
    private var settings: AppSettings { AppSettings.shared }
    private var showingGridView: Bool { settings.defaultViewMode == .grid }
    private var currentSortOption: SortOption { settings.currentSortOption }
    private var showViewToggle: Bool { settings.showViewToggle }
    private var showSortPicker: Bool { settings.showSortPicker }
    private var showAttachmentIcons: Bool { settings.showAttachmentIcons }
    private var enableNFC: Bool { settings.enableNFC }
    private var enableQR: Bool { settings.enableQR }
    
    init() {
        let sortOption = AppSettings.shared.currentSortOption
        let sortDescriptors = Self.sortDescriptors(for: sortOption)
        _allItems = Query(sort: sortDescriptors)
    }
    
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
                // The "Show Archived" button should always be present if there are archived items
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
                
                if filteredItems.isEmpty && !searchText.isEmpty {
                    SearchEmptyView(searchText: searchText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.secondaryBackground)
                } else if currentItems.isEmpty {
                    if showArchivedItems {
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
                        .id(settingsRefreshId)
                    } else {
                        BandedItemListView(
                            items: filteredItems,
                            showAttachmentIcons: showAttachmentIcons,
                            isShowingArchived: showArchivedItems
                        )
                        .background(AppTheme.secondaryBackground)
                        .id(settingsRefreshId)
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
                
                ToolbarItem(placement: .principal) {
                    Text(showArchivedItems ? "Archived Items" : "Items")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !currentItems.isEmpty && !showingSearch {
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
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddItem) {
                AddEditItemView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .onChange(of: showingSettings) { _, isShowing in
                if !isShowing {
                    settingsRefreshId = UUID()
                }
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
                    HStack(spacing: 16) {
                        if enableNFC {
                            Button(action: { showingNFCScanner = true }) {
                                Image(systemName: "wave.3.right")
                            }
                        }
                        
                        if enableQR {
                            Button(action: { showingQRScanner = true }) {
                                Image(systemName: "qrcode.viewfinder")
                            }
                        }
                    }
                    
                    Spacer()
                    
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
        }
        .overlay(alignment: .top) {
            Group {
                if showingSearch {
                    ZStack(alignment: .bottom) {
                        if !archivedItems.isEmpty {
                            Color.clear
                                .frame(height: 132) // A generous height to cover the toolbar and button
                                .background(.ultraThinMaterial)
                        } else {
                            Color.clear
                                .frame(height: 108) // A shorter height for just the toolbar
                                .background(.ultraThinMaterial)
                        }

                        // The Search bar itself
                        HStack(spacing: 8) {
                            SearchBar(text: $searchText)
                            
                            Button("Cancel") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingSearch = false
                                    searchText = ""
                                }
                            }
                            .font(.system(size: 16))
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        // This is the key change to conditionally adjust the position
                        .padding(.bottom, !archivedItems.isEmpty ? 36 : 12)
                    }
                    .ignoresSafeArea(.container, edges: .top)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
    
    // MARK: - Other Functions
    
    private func updateSortOption(_ option: SortOption) {
        AppSettings.shared.currentSortOption = option
        settingsRefreshId = UUID()
    }
    
    private func toggleViewMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            let newMode: ViewMode = showingGridView ? .list : .grid
            AppSettings.shared.defaultViewMode = newMode
            settingsRefreshId = UUID()
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
        if let item = allItems.first(where: { $0.id == itemID }) {
            item.recordView()
        } else {
            showingNFCItemNotFound = true
        }
    }
    
    private func handleQRScan(itemID: UUID) {
        if let item = allItems.first(where: { $0.id == itemID }) {
            item.recordView()
        } else {
            showingQRItemNotFound = true
        }
    }
    
    private func handleDeepLink(url: URL) {
        print("Received deep link: \(url)")
        
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
