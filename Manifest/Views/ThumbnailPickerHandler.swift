//
//  ThumbnailPickerHandler.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI

struct ThumbnailPickerHandler: View {
    @Binding var selectedEmoji: String?
    @Binding var showingThumbnailPicker: Bool
    let item: Item?
    let tempItem: Item?
    let editableItem: Item
    
    var body: some View {
        Color.clear
            .sheet(isPresented: $showingThumbnailPicker) {
                NavigationView {
                    ThumbnailSelectionView(
                        item: editableItem,
                        onSelectionMade: handleThumbnailSelection,
                        onEmojiSelected: handleEmojiSelection
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingThumbnailPicker = false
                            }
                        }
                    }
                }
            }
    }
    
    private func handleThumbnailSelection(_ selectedThumbnailImage: UIImage?) {
        print("🖼️ Thumbnail selected: \(selectedThumbnailImage != nil ? "Image" : "Emoji")")
        
        // If we're setting an image thumbnail, clear the emoji form state
        if selectedThumbnailImage != nil {
            selectedEmoji = nil
        }
        
        if let existingItem = item {
            print("📝 Setting thumbnail on existing item")
            existingItem.setThumbnailImage(selectedThumbnailImage)
        } else {
            print("🆕 Setting thumbnail on temp item")
            tempItem?.setThumbnailImage(selectedThumbnailImage)
        }
    }
    
    private func handleEmojiSelection(_ selectedEmojiString: String?) {
        print("😀 Emoji selected: \(selectedEmojiString ?? "nil")")
        // Update the form state first
        selectedEmoji = selectedEmojiString
        
        // Then update the item
        if let existingItem = item {
            print("📝 Setting emoji on existing item")
            existingItem.setEmojiPlaceholder(selectedEmojiString)
        } else {
            print("🆕 Setting emoji on temp item")
            tempItem?.setEmojiPlaceholder(selectedEmojiString)
        }
    }
}
