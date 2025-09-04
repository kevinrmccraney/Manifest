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
    @State private var showingGridView = false
    @State private var showingSearch = false
    @State private var searchText = ""
    
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
                        GridView(items: filteredItems)
                            .background(AppTheme.secondaryBackground)
                    } else {
                        BandedItemListView(items: filteredItems)
                            .background(AppTheme.secondaryBackground)
                    }
                }
            }
            .background(AppTheme.primaryBackground) // Top area white/black
            .navigationTitle("Manifest")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !allItems.isEmpty {
                        Button(action: toggleSearch) {
                            Image(systemName: "magnifyingglass")
                        }
                        
                        Button(action: toggleViewMode) {
                            Image(systemName: showingGridView ? "list.bullet" : "square.grid.2x2")
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
        }
        .background(AppTheme.secondaryBackground.ignoresSafeArea()) // Overall grey background
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
}
