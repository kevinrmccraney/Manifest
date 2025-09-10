//
//  ImageDisplaySection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ImageDisplaySection: View {
    let item: Item
    
    var body: some View {
        if let image = item.thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .cornerRadius(12)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    Text(item.effectiveEmojiPlaceholder)
                        .font(.system(size: 80))
                )
        }
    }
}
