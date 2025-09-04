//
//  AppTheme.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct AppTheme {
    // Background colors
    static let primaryBackground = Color(.systemBackground) // White/Black for top areas
    static let secondaryBackground = Color(.systemGray6) // Grey background
    static let tertiaryBackground = Color(.systemGray5) // Slightly darker grey
    
    // Row colors for banding
    static let evenRowBackground = Color(.systemBackground) // White/Black
    static let oddRowBackground = Color(.systemGray6).opacity(0.5) // Light grey
    
    // Card colors
    static let cardBackground = Color(.systemBackground)
    static let cardShadow = Color.black.opacity(0.1)
}
