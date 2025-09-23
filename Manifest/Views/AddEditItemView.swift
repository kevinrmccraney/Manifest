//
//  AddEditItemView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct AddEditItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var selectedEmoji: String?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var showingThumbnailPicker = false
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var attachments: [FileAttachment] = []
    @State private var itemID: UUID = UUID() // Create UUID immediately
    @State private var contextFlags: ItemContextFlags = ItemContextFlags()
    @State private var tempItem: Item? // Add this to hold the temporary item for new items
    
    @State private var enabledNFCScanning = AppSettings.shared.enableNFC
    @State private var enabledQRScanning = AppSettings.shared.enableQR
    
    // NFC related state
    @State private var showingNFCWriter = false
    
    let item: Item?
    
    // Create a persistent item for thumbnail selection
    private var editableItem: Item {
        if let existingItem = item {
            return existingItem
        } else {
            // Return the temp item if it exists, otherwise create it
            if let tempItem = tempItem {
                return tempItem
            } else {
                // This shouldn't happen, but create a fallback
                let fallbackItem = Item(name: name.isEmpty ? "New Item" : name)
                fallbackItem.id = itemID
                return fallbackItem
            }
        }
    }
    
    init(item: Item? = nil) {
        self.item = item
        if let item = item {
            _name = State(initialValue: item.name)
            _description = State(initialValue: item.itemDescription)
            _selectedImage = State(initialValue: item.thumbnailImage)
            _selectedEmoji = State(initialValue: item.emojiPlaceholder)
            _tags = State(initialValue: item.tags)
            _attachments = State(initialValue: item.attachments)
            _itemID = State(initialValue: item.id) // Use existing ID for editing
            _contextFlags = State(initialValue: item.contextFlags)
            _tempItem = State(initialValue: nil) // Existing items don't need a temp item
        } else {
            _tempItem = State(initialValue: nil) // Will be created lazily
        }
        // For new items, itemID is already initialized with UUID()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FormContentView(
                    name: $name,
                    description: $description,
                    selectedEmoji: $selectedEmoji,
                    tags: $tags,
                    newTag: $newTag,
                    contextFlags: $contextFlags,
                    attachments: $attachments,
                    showingThumbnailPicker: $showingThumbnailPicker,
                    item: item,
                    tempItem: tempItem,
                    editableItem: editableItem,
                    updateTempItemAttachments: updateTempItemAttachments,
                    enabledNFCScanning: enabledNFCScanning,
                    enabledQRScanning: enabledQRScanning,
                    showingNFCWriter: $showingNFCWriter,
                    itemID: itemID
                )
            }
            .onAppear {
                initializeTempItemIfNeeded()
            }
            .background(
                ThumbnailPickerHandler(
                    selectedEmoji: $selectedEmoji,
                    showingThumbnailPicker: $showingThumbnailPicker,
                    item: item,
                    tempItem: tempItem,
                    editableItem: editableItem
                )
            )
            .navigationTitle(item == nil ? "Add Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingNFCWriter) {
                NFCWriterView(
                    itemID: itemID,
                    itemName: name.isEmpty ? "Untitled Item" : name
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // Initialize the temporary item when the view appears
    private func initializeTempItemIfNeeded() {
        if item == nil && tempItem == nil {
            let newTempItem = Item(name: name.isEmpty ? "New Item" : name)
            newTempItem.id = itemID
            newTempItem.setThumbnailImage(selectedImage)
            newTempItem.setEmojiPlaceholder(selectedEmoji)
            newTempItem.attachments = attachments
            tempItem = newTempItem
        }
    }
    
    // Update temp item attachments when the attachments array changes
    private func updateTempItemAttachments() {
        if item == nil {
            tempItem?.attachments = attachments
        }
    }
    
    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Saving item with \(attachments.count) attachments")
        print("Selected emoji: \(String(describing: selectedEmoji))")
        
        for (index, attachment) in attachments.enumerated() {
            print("Attachment \(index): \(attachment.filename) (ID: \(attachment.id))")
        }
        
        if let existingItem = item {
            // Edit existing item
            existingItem.name = trimmedName
            existingItem.itemDescription = trimmedDescription
            existingItem.tags = tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            existingItem.contextFlags = contextFlags

            // Don't override emoji/thumbnail - they've already been set through the thumbnail picker
            // Only update if the form state is different and more recent
            print("💾 Save - Form selectedEmoji: \(String(describing: selectedEmoji))")
            print("💾 Save - Item emojiPlaceholder: \(String(describing: existingItem.emojiPlaceholder))")
            print("💾 Save - Item has thumbnail: \(existingItem.thumbnailData != nil)")
            
            // Sync attachments more carefully
            // Remove attachments that are no longer in our state
            existingItem.attachments.removeAll { existingAttachment in
                !attachments.contains { $0.id == existingAttachment.id }
            }
            
            // Add new attachments that aren't already in the item
            for attachment in attachments {
                if !existingItem.attachments.contains(where: { $0.id == attachment.id }) {
                    attachment.item = existingItem
                    modelContext.insert(attachment)
                    existingItem.attachments.append(attachment)
                }
            }
        } else {
            // Create new item with the pre-generated UUID
            // Create new item with the pre-generated UUID
            let newItem = Item(
                name: trimmedName,
                itemDescription: trimmedDescription,
                thumbnailData: nil,
                customFields: nil,
                tags: tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                isArchived: false,
                isPinned: false,
                emojiPlaceholder: selectedEmoji
            )

            // Override the auto-generated ID with our pre-generated one
            newItem.id = itemID
            newItem.contextFlags = contextFlags

            // Copy thumbnail and emoji state from tempItem if it exists
            if let tempItem = tempItem {
                newItem.setThumbnailImage(tempItem.thumbnailImage)
                newItem.setEmojiPlaceholder(tempItem.emojiPlaceholder ?? selectedEmoji)
            }

            print("Created new item with emoji: \(String(describing: newItem.emojiPlaceholder))")
            
            // Add attachments
            for attachment in attachments {
                attachment.item = newItem
                modelContext.insert(attachment)
                newItem.attachments.append(attachment)
            }
            
            modelContext.insert(newItem)
        }
        
        dismiss()
    }
}

// MARK: - Current Item Header

struct CurrentItemHeader: View {
    let itemName: String
    let thumbnailImage: UIImage?
    let emojiPlaceholder: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Editing Item")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                // Small thumbnail/emoji
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipped()
                        .cornerRadius(6)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(emojiPlaceholder)
                                .font(.system(size: 20))
                        )
                }
                
                Text(itemName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
            }
        }
    }
}
