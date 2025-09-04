//
//  Customfield.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import Foundation

struct CustomField: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String
    
    static func == (lhs: CustomField, rhs: CustomField) -> Bool {
        lhs.id == rhs.id
    }
}
