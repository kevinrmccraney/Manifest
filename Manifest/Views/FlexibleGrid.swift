//
//  FlexibleGrid.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-19.
//

import SwiftUI

struct FlexibleGrid<Content: View>: View {
    let items: [AnyHashable]
    let itemsPerRow: Int
    let spacing: CGFloat
    let content: (Int) -> Content
    
    init<T: Hashable>(items: [T], itemsPerRow: Int = 4, spacing: CGFloat = 16, @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items.map { AnyHashable($0) }
        self.itemsPerRow = itemsPerRow
        self.spacing = spacing
        self.content = { index in
            if let item = items[safe: index] {
                return content(item)
            } else {
                return content(items[0]) // This shouldn't happen but prevents crashes
            }
        }
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<numberOfRows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<itemsPerRow, id: \.self) { column in
                        let index = row * itemsPerRow + column
                        if index < items.count {
                            content(index)
                        } else {
                            // Empty space to maintain alignment
                            Color.clear.frame(width: 80, height: 80)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var numberOfRows: Int {
        (items.count + itemsPerRow - 1) / itemsPerRow
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
