//
//  ThumbnailSelectionView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI

struct ThumbnailSelectionView: View {
    @Bindable var item: Item
    @Environment(\.dismiss) private var dismiss
    let onSelectionMade: ((UIImage?) -> Void)
    let onEmojiSelected: ((String?) -> Void)?
    @State private var showingEmojiPicker = false
    
    // Get all image attachments
    private var imageAttachments: [FileAttachment] {
        item.attachments.filter { $0.isImage }
    }
    
    // Check if current thumbnail matches any attachment
    private func isCurrentThumbnail(_ attachment: FileAttachment) -> Bool {
        guard let thumbnailData = item.thumbnailData else { return false }
        return thumbnailData == attachment.fileData
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Emoji Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Emoji")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        CurrentEmojiOption(
                            item: item,
                            onEmojiSelected: onEmojiSelected,
                            onSelectionMade: onSelectionMade,
                            dismiss: { dismiss() }
                        )
                        
                        ChooseEmojiOption(showingEmojiPicker: $showingEmojiPicker)
                        
                        Spacer()
                    }
                }
                
                // Images Section (only show if there are image attachments)
                if !imageAttachments.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Images")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        // Simple: just put all images in a flow layout - 4 wide
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                            alignment: .leading,
                            spacing: 16
                        ) {
                            ForEach(imageAttachments, id: \.id) { attachment in
                                ImageThumbnailOption(
                                    attachment: attachment,
                                    onSelectionMade: onSelectionMade,
                                    onEmojiSelected: onEmojiSelected,
                                    isCurrentThumbnail: isCurrentThumbnail,
                                    dismiss: { dismiss() }
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Choose Thumbnail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEmojiPicker) {
            EmojiPickerSheet(
                onEmojiSelected: onEmojiSelected,
                onSelectionMade: onSelectionMade,
                showingEmojiPicker: $showingEmojiPicker
            )
        }
    }
}

// MARK: - Emoji Selection Section

struct EmojiSelectionSection: View {
    let item: Item
    let onEmojiSelected: ((String?) -> Void)?
    let onSelectionMade: ((UIImage?) -> Void)
    @Binding var showingEmojiPicker: Bool
    let dismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Emoji")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Current emoji option
                CurrentEmojiOption(
                    item: item,
                    onEmojiSelected: onEmojiSelected,
                    onSelectionMade: onSelectionMade,
                    dismiss: dismiss
                )
                
                // Choose new emoji option
                ChooseEmojiOption(showingEmojiPicker: $showingEmojiPicker)
                
                Spacer()
            }
        }
    }
}

// MARK: - Current Emoji Option

struct CurrentEmojiOption: View {
    let item: Item
    let onEmojiSelected: ((String?) -> Void)?
    let onSelectionMade: ((UIImage?) -> Void)
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(item.effectiveEmojiPlaceholder)
                        .font(.system(size: 32))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(item.thumbnailData == nil ? Color.blue : Color.clear, lineWidth: 3)
                )
                .onTapGesture {
                    selectCurrentEmoji()
                }
            
            Text("Current")
                .font(.caption2)
                .foregroundStyle(item.thumbnailData == nil ? .blue : .secondary)
                .fontWeight(.medium)
        }
    }
    
    private func selectCurrentEmoji() {
        print("🎯 Selecting current emoji: \(item.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder)")
        onSelectionMade(nil)
        onEmojiSelected?(item.emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder)
        print("🔄 Dismissing thumbnail picker")
        dismiss()
    }
}

// MARK: - Choose Emoji Option

struct ChooseEmojiOption: View {
    @Binding var showingEmojiPicker: Bool
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "face.smiling")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                )
                .onTapGesture {
                    showingEmojiPicker = true
                }
            
            Text("Choose")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Image Selection Section

struct ImageSelectionSection: View {
    let imageAttachments: [FileAttachment]
    let onSelectionMade: ((UIImage?) -> Void)
    let onEmojiSelected: ((String?) -> Void)?
    let isCurrentThumbnail: (FileAttachment) -> Bool
    let dismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Images")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            // Center the images in a flexible layout
            HStack(spacing: 16) {
                ForEach(imageAttachments, id: \.id) { attachment in
                    ImageThumbnailOption(
                        attachment: attachment,
                        onSelectionMade: onSelectionMade,
                        onEmojiSelected: onEmojiSelected,
                        isCurrentThumbnail: isCurrentThumbnail,
                        dismiss: dismiss
                    )
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Image Thumbnail Option

struct ImageThumbnailOption: View {
    let attachment: FileAttachment
    let onSelectionMade: ((UIImage?) -> Void)
    let onEmojiSelected: ((String?) -> Void)?
    let isCurrentThumbnail: (FileAttachment) -> Bool
    let dismiss: () -> Void
    
    var body: some View {
        VStack {
            if let image = UIImage(data: attachment.fileData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrentThumbnail(attachment) ? Color.blue : Color.clear, lineWidth: 3)
                    )
                    .onTapGesture {
                        selectImage(image)
                    }
                
                Text(attachment.filename)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: 80) // Match the image width
                
                if isCurrentThumbnail(attachment) {
                    Text("Current")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private func selectImage(_ image: UIImage) {
        print("🖼️ Selecting image thumbnail")
        onSelectionMade(image)
        onEmojiSelected?(nil) // Clear emoji when selecting image
        print("🔄 Dismissing thumbnail picker")
        dismiss()
    }
}

// MARK: - Emoji Picker Sheet

struct EmojiPickerSheet: View {
    let onEmojiSelected: ((String?) -> Void)?
    let onSelectionMade: ((UIImage?) -> Void)
    @Binding var showingEmojiPicker: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 12) {
                    ForEach(EmojiCategory.allCases.flatMap { $0.emojis }, id: \.self) { emoji in
                        Button(action: {
                            selectEmoji(emoji)
                        }) {
                            Text(emoji)
                                .font(.system(size: 32))
                                .frame(width: 44, height: 44)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingEmojiPicker = false
                    }
                }
            }
        }
    }
    
    private func selectEmoji(_ emoji: String) {
        print("😀 Selecting new emoji: \(emoji)")
        onSelectionMade(nil) // Clear any image thumbnail
        onEmojiSelected?(emoji)
        print("🔄 Dismissing emoji picker")
        showingEmojiPicker = false
    }
}
