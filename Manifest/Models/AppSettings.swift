//
//  AppSettings.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import Foundation

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
    
    // Show attachment icons setting
    var showAttachmentIcons: Bool {
        get {
            // Default to true if not set
            if UserDefaults.standard.object(forKey: "showAttachmentIcons") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "showAttachmentIcons")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showAttachmentIcons")
        }
    }
    
    private init() {}
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
