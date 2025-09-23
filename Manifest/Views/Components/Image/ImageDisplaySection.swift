//
//  ImageDisplaySection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ImageDisplaySection: View {
    let item: Item
    let frameHeight: CGFloat = 200
    
    var body: some View {
        if let image = item.thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: frameHeight)
                .cornerRadius(12)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: frameHeight)
                .overlay(
                    Text(item.effectiveEmojiPlaceholder)
                        .font(.system(size: frameHeight * 0.4))
                )
        }
    }}
