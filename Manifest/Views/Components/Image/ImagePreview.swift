//
//  ImagePreview.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ImagePreview: View {
    let image: UIImage?
    let emojiPlaceholder: String?
    
    // Convenience initializer for backward compatibility
    init(image: UIImage?) {
        self.image = image
        self.emojiPlaceholder = nil
    }
    
    init(image: UIImage?, emojiPlaceholder: String?) {
        self.image = image
        self.emojiPlaceholder = emojiPlaceholder
    }
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .cornerRadius(8)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder)
                        .font(.system(size: 30))
                )
        }
    }
}
