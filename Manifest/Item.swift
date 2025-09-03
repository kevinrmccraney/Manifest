//
//  Item.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
