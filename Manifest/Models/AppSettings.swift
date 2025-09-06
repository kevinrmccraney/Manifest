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
        get { bool(forKey: "showAttachmentIcons", default: true) }
        set { UserDefaults.standard.set(newValue, forKey: "showAttachmentIcons") }
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
