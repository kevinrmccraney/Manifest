//
//  AppSettings.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import Foundation
import SwiftUI

// Sort options enum
enum SortOption: String, CaseIterable {
    case nameAscending = "nameAscending"
    case nameDescending = "nameDescending"
    case newestFirst = "newestFirst"
    case oldestFirst = "oldestFirst"
    case recentlyModified = "recentlyModified"
    case oldestModified = "oldestModified"
    case recentlyViewed = "recentlyViewed"
    case frequentlyViewed = "frequentlyViewed"
    
    var displayName: String {
        switch self {
        case .nameAscending:
            return "Name (A-Z)"
        case .nameDescending:
            return "Name (Z-A)"
        case .newestFirst:
            return "Newest First"
        case .oldestFirst:
            return "Oldest First"
        case .recentlyModified:
            return "Recently Modified"
        case .oldestModified:
            return "Oldest Modified"
        case .recentlyViewed:
            return "Recently Viewed"
        case .frequentlyViewed:
            return "Frequently Viewed"
        }
    }
    
    var icon: String {
        switch self {
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc"
        case .newestFirst:
            return "clock.badge.checkmark"
        case .oldestFirst:
            return "clock.badge"
        case .recentlyModified:
            return "pencil.circle"
        case .oldestModified:
            return "pencil.circle"
        case .recentlyViewed:
            return "eye.circle"
        case .frequentlyViewed:
            return "eye.circle.fill"
        }
    }
}

@Observable
class AppSettings {
    static let shared = AppSettings()
    
    // Default view mode setting
    var defaultViewMode: ViewMode {
        get {
            if let savedMode = UserDefaults.standard.string(forKey: "defaultViewMode"),
               let mode = ViewMode(rawValue: savedMode) {
                return mode
            }
            return .list // Default to list view
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "defaultViewMode")
        }
    }
    
    // Default sort option
    var defaultSortOption: SortOption {
        get {
            if let savedSort = UserDefaults.standard.string(forKey: "defaultSortOption"),
               let sortOption = SortOption(rawValue: savedSort) {
                return sortOption
            }
            return .newestFirst // Default to newest first
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "defaultSortOption")
        }
    }
    
    // Current sort option (separate from default, for session persistence)
    var currentSortOption: SortOption {
        get {
            if let savedSort = UserDefaults.standard.string(forKey: "currentSortOption"),
               let sortOption = SortOption(rawValue: savedSort) {
                return sortOption
            }
            return defaultSortOption
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "currentSortOption")
        }
    }
    
    // Default emoji placeholder for items without images
    var defaultEmojiPlaceholder: String {
        get {
            return UserDefaults.standard.string(forKey: "defaultEmojiPlaceholder") ?? "📦"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "defaultEmojiPlaceholder")
        }
    }
    
    // Show attachment icons setting
    var showAttachmentIcons: Bool {
        get { bool(forKey: "showAttachmentIcons", default: true) }
        set { UserDefaults.standard.set(newValue, forKey: "showAttachmentIcons") }
    }
    
    var showSortPicker: Bool {
        get { bool(forKey: "showSortPicker", default: true) }
        set { UserDefaults.standard.set(newValue, forKey: "showSortPicker") }
    }
    
    var enableNFC: Bool {
        get { bool(forKey: "enableNFC", default: false) }
        set { UserDefaults.standard.set(newValue, forKey: "enableNFC") }
    }
    
    var enableQR: Bool {
        get { bool(forKey: "enableQR", default: false) }
        set { UserDefaults.standard.set(newValue, forKey: "enableQR") }
    }
    
    var debugMode: Bool {
        get { bool(forKey: "debugMode", default: false) }
        set { UserDefaults.standard.set(newValue, forKey: "debugMode") }
    }
    
    var showViewToggle: Bool {
        get { bool(forKey: "showViewToggle", default: false) }
        set { UserDefaults.standard.set(newValue, forKey: "showViewToggle") }
    }
    
    var globalSearch: Bool {
        get { bool(forKey: "globalSearch", default: true) }
        set { UserDefaults.standard.set(newValue, forKey: "globalSearch") }
    }

    var showItemDescriptions: Bool {
        get { bool(forKey: "showItemDescriptions", default: true) }
        set { UserDefaults.standard.set(newValue, forKey: "showItemDescriptions") }
    }
    
    private init() {}
}

func bool(forKey key: String, default defaultValue: Bool) -> Bool {
    if let value = UserDefaults.standard.object(forKey: key) as? Bool {
        return value
    }
    return defaultValue
}

enum ViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"
    
    var displayName: String {
        switch self {
        case .list:
            return "List"
        case .grid:
            return "Grid"
        }
    }
    
    var icon: String {
        switch self {
        case .list:
            return "list.bullet"
        case .grid:
            return "square.grid.2x2"
        }
    }
}
