//
//  ItemContextFlags.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//


//
//  ItemContextFlags.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-12.
//

import Foundation

struct ItemContextFlags: Codable {
    var isFragile: Bool = false
    var isHeavy: Bool = false
    // Future context flags can be added here:
    // var isLiquid: Bool = false
    // var requiresRefrigeration: Bool = false
    // var isValuable: Bool = false
    
    init(isFragile: Bool = false, isHeavy: Bool = false) {
        self.isFragile = isFragile
        self.isHeavy = isHeavy
    }
    
    var hasAnyFlags: Bool {
        return isFragile || isHeavy
    }
}

enum ContextBadgeType {
    case fragile
    case heavy
    
    var letter: String {
        switch self {
        case .fragile: return "F"
        case .heavy: return "H"
        }
    }
    
    var color: String {
        switch self {
        case .fragile: return "red"
        case .heavy: return "green"
        }
    }
    
    var displayName: String {
        switch self {
        case .fragile: return "Fragile"
        case .heavy: return "Heavy"
        }
    }
}