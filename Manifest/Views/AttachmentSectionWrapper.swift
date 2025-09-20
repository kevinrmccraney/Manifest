//
//  AttachmentSectionWrapper.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI

struct AttachmentSectionWrapper: View {
    @Binding var attachments: [FileAttachment]
    @Binding var selectedEmoji: String?
    let item: Item?
    let tempItem: Item?
    let editableItem: Item
    let updateTempItemAttachments: () -> Void
    
    var body: some View {
        FileAttachmentSection(
            attachments: $attachments,
            item: editableItem,
            onThumbnailSelected: handleThumbnailSelection,
            onEmojiSelected: handleEmojiSelection
        )
        .onChange(of: attachments) { _, _ in
            updateTempItemAttachments()
        }
    }
    
    private func handleThumbnailSelection(_ selectedThumbnailImage: UIImage?) {
        print("🖼️ AttachmentSection - Thumbnail selected: \(selectedThumbnailImage != nil ? "Image" : "Emoji")")
        
        // If we're setting an image thumbnail, clear the emoji form state
        if selectedThumbnailImage != nil {
            selectedEmoji = nil
        }
        
        if let existingItem = item {
            print("📝 AttachmentSection - Setting thumbnail on existing item")
            existingItem.setThumbnailImage(selectedThumbnailImage)
        } else {
            print("🆕 AttachmentSection - Setting thumbnail on temp item")
            tempItem?.setThumbnailImage(selectedThumbnailImage)
        }
    }
    
    private func handleEmojiSelection(_ selectedEmojiString: String?) {
        print("😀 AttachmentSection - Emoji selected: \(selectedEmojiString ?? "nil")")
        // Update the form state first
        selectedEmoji = selectedEmojiString
        
        // Then update the item
        if let existingItem = item {
            print("📝 AttachmentSection - Setting emoji on existing item")
            existingItem.setEmojiPlaceholder(selectedEmojiString)
        } else {
            print("🆕 AttachmentSection - Setting emoji on temp item")
            tempItem?.setEmojiPlaceholder(selectedEmojiString)
        }
    }
}
