//
//  ItemDetailsFormSection.swift
//  Manifest
//
//  Simplified item details form section
//

import SwiftUI

struct ItemDetailsWithEmojiFormSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedEmoji: String?
    let onEmojiTapped: () -> Void
    let item: Item?
    
    var body: some View {
        Section(header: Text("Item Details")) {
            FormFieldView(label: "Name", text: $name, placeholder: "Item name")
            FormTextEditorView(label: "Description", text: $description)
        }
        
        ThumbnailFormSection(
            selectedEmoji: $selectedEmoji,
            item: item,
            onEmojiTapped: onEmojiTapped
        )
    }
}

// MARK: - Reusable Form Components

private struct FormFieldView: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct FormTextEditorView: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            TextEditor(text: $text)
                .frame(minHeight: 60)
        }
    }
}

private struct ThumbnailFormSection: View {
    @Binding var selectedEmoji: String?
    let item: Item?
    let onEmojiTapped: () -> Void
    
    private var hasImageThumbnail: Bool {
        item?.thumbnailData != nil
    }
    
    private var effectiveEmoji: String {
        if let item = item, hasImageThumbnail {
            return item.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder
        } else {
            return selectedEmoji ?? item?.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder
        }
    }
    
    var body: some View {
        Section(header: Text("Thumbnail")) {
            HStack {
                ThumbnailPreviewButton(
                    item: item,
                    effectiveEmoji: effectiveEmoji,
                    onTapped: onEmojiTapped
                )
                
                ThumbnailControlsView(
                    hasImageThumbnail: hasImageThumbnail,
                    hasCustomEmoji: selectedEmoji != nil || item?.emojiPlaceholder != nil,
                    onChooseThumbnail: onEmojiTapped,
                    onUseDefault: {
                        item?.setThumbnailImage(nil)
                        item?.setEmojiPlaceholder(nil)
                        selectedEmoji = nil
                    }
                )
                
                Spacer()
            }
        }
    }
}

private struct ThumbnailPreviewButton: View {
    let item: Item?
    let effectiveEmoji: String
    let onTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(width: 60, height: 60)
                .overlay(
                    Group {
                        if let thumbnailImage = item?.thumbnailImage {
                            Image(uiImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(12)
                        } else {
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
    }
}

private struct ThumbnailControlsView: View {
    let hasImageThumbnail: Bool
    let hasCustomEmoji: Bool
    let onChooseThumbnail: () -> Void
    let onUseDefault: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Choose Thumbnail") {
                onChooseThumbnail()
            }
            .buttonStyle(.bordered)
            
            if hasImageThumbnail || hasCustomEmoji {
                Button("Use Default Thumbnail") {
                    onUseDefault()
                }
                .foregroundStyle(.orange)
                .font(.caption)
            }
            
            if !hasImageThumbnail {
                Text("Using app default thumbnail")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
