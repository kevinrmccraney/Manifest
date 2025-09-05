//
//  NavigationCoordinator.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//


//
//  NavigationCoordinator.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI
import Combine

@Observable
class NavigationCoordinator {
    static let shared = NavigationCoordinator()
    
    var selectedItem: Item?
    var showingItemDetail = false
    
    private init() {}
    
    func navigateToItem(_ item: Item) {
        selectedItem = item
        showingItemDetail = true
    }
    
    func clearSelection() {
        selectedItem = nil
        showingItemDetail = false
    }
}