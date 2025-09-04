//
//  TitleDescriptionSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct TitleDescriptionSection: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !item.itemDescription.isEmpty {
                Text(item.itemDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}
