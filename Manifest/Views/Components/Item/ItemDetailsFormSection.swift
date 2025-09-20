//
//  ItemDetailsWithEmojiFormSection.swift
//  Manifest
//
//  Updated to integrate emoji selection with thumbnail system
//

import SwiftUI

struct ItemDetailsWithEmojiFormSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedEmoji: String?
    let onEmojiTapped: () -> Void
    let item: Item?
    
    // Check if current thumbnail is an image (not emoji)
    private var hasImageThumbnail: Bool {
        item?.thumbnailData != nil
    }
    
    // Get the current thumbnail image if it exists
    private var currentThumbnailImage: UIImage? {
        item?.thumbnailImage
    }
    
    // Get the effective emoji (selected emoji or item's emoji or default)
    private var effectiveEmoji: String {
        if let item = item, hasImageThumbnail {
            // If we have an image thumbnail, show the item's emoji or default
            return item.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder
        } else {
            // Otherwise use the selected emoji or item's emoji or default
            return selectedEmoji ?? item?.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder
        }
    }
    
    var body: some View {
        Section(header: Text("Item Details")) {
            // Name field
            HStack {
                Text("Name")
                    .foregroundStyle(.secondary)
                TextField("Item name", text: $name)
                    .multilineTextAlignment(.trailing)
            }
            
            // Description field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Description")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                TextEditor(text: $description)
                    .frame(minHeight: 60)
            }
        }
        
        Section(header: Text("Thumbnail")) {
            HStack {
                // Show current thumbnail (emoji or image)
                Button(action: onEmojiTapped) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Group {
                                if let thumbnailImage = currentThumbnailImage {
                                    // Show image thumbnail
                                    Image(uiImage: thumbnailImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipped()
                                        .cornerRadius(12)
                                } else {
                                    // Show emoji thumbnail
                                    Text(effectiveEmoji)
                                        .font(.system(size: 32))
                                }
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Button("Choose Thumbnail") {
                        onEmojiTapped()
                    }
                    .buttonStyle(.bordered)
                    
                    // Show "Use Default Thumbnail" button if we have an image thumbnail or custom emoji
                    if hasImageThumbnail || selectedEmoji != nil || item?.emojiPlaceholder != nil {
                        Button("Use Default Thumbnail") {
                            // Reset to default emoji
                            if let existingItem = item {
                                existingItem.setThumbnailImage(nil)
                                existingItem.setEmojiPlaceholder(nil)
                            }
                            selectedEmoji = nil
                        }
                        .foregroundStyle(.orange)
                        .font(.caption)
                    }
                    
                    // Status text
                    if hasImageThumbnail == false {
                        Text("Using app default thumbnail")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .id("thumbnail-\(hasImageThumbnail)-\(selectedEmoji ?? "none")-\(item?.emojiPlaceholder ?? "none")")
    }
}
