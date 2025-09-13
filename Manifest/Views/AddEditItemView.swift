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
    @State private var showingEmojiPicker = false
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var attachments: [FileAttachment] = []
    @State private var itemID: UUID = UUID() // Create UUID immediately
    @State private var contextFlags: ItemContextFlags = ItemContextFlags()
    
    @State private var enabledNFCScanning = AppSettings.shared.enableNFC
    @State private var enabledQRScanning = AppSettings.shared.enableQR
    
    // NFC related state
    @State private var showingNFCWriter = false
    
    // Legacy support
    @State private var selectedFileURL: URL?
    @State private var attachmentDescription = ""
    @State private var showingFilePicker = false
    
    let item: Item?
    
    init(item: Item? = nil) {
        self.item = item
        if let item = item {
            _name = State(initialValue: item.name)
            _description = State(initialValue: item.itemDescription)
            _selectedImage = State(initialValue: item.thumbnailImage)
            _selectedEmoji = State(initialValue: item.emojiPlaceholder)
            _tags = State(initialValue: item.tags)
            _attachments = State(initialValue: item.attachments)
            _attachmentDescription = State(initialValue: item.attachmentDescription ?? item.attachmentFilename ?? "")
            _itemID = State(initialValue: item.id) // Use existing ID for editing
            _contextFlags = State(initialValue: item.contextFlags)
        }
        // For new items, itemID is already initialized with UUID()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Current item name header (only show when editing)
                if let item = item {
                    CurrentItemHeader(
                        itemName: item.name,
                        thumbnailImage: item.thumbnailImage,
                        emojiPlaceholder: item.effectiveEmojiPlaceholder
                    )
                    .padding()
                    .background(AppTheme.primaryBackground)
                    
                    Divider()
                }
                
                Form {
                    ItemDetailsWithEmojiFormSection(
                        name: $name,
                        description: $description,
                        selectedEmoji: $selectedEmoji,
                        onEmojiTapped: {
                            showingEmojiPicker = true
                        }
                    )
                    
                    TagsFormSection(
                        tags: $tags,
                        newTag: $newTag
                    )
                    
                    ImageFormSection(
                        selectedImage: $selectedImage,
                        selectedEmoji: $selectedEmoji,
                        showingActionSheet: $showingActionSheet
                    )
                    
                    ContextFormSection(contextFlags: $contextFlags)
                    
                    MultiFileAttachmentFormSection(attachments: $attachments)
                    
                    if enabledQRScanning || enabledNFCScanning {
                        // Physical Storage Section (combines QR Code and NFC)
                        Section(header: Text("Physical Storage")) {
                            
                            if enabledQRScanning {
                                QRCodeGeneratorContent(
                                    item: item,
                                    itemName: name.isEmpty ? "Untitled Item" : name,
                                    itemID: itemID,
                                    attachments: $attachments
                                )
                            }
                            
                            if enabledNFCScanning {
                                // NFC Tag Creation
                                Button(action: {
                                    showingNFCWriter = true
                                }) {
                                    HStack {
                                        Image(systemName: "wave.3.right.circle.fill")
                                            .foregroundStyle(.blue)
                                        Text("Create NFC Tag")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                    }
                }
            }
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
            .sheet(isPresented: $showingEmojiPicker) {
                MessagesStyleEmojiPicker(selectedEmoji: $selectedEmoji)
            }
            .confirmationDialog("Select Image", isPresented: $showingActionSheet) {
                Button("Camera") {
                    showingCamera = true
                }
                Button("Photo Library") {
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .sheet(isPresented: $showingNFCWriter) {
                NFCWriterView(
                    itemID: itemID,
                    itemName: name.isEmpty ? "Untitled Item" : name
                )
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.item], // Allows all file types
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    selectedFileURL = selectedFile
                    if attachmentDescription.isEmpty {
                        attachmentDescription = selectedFile.lastPathComponent
                    }
                } catch {
                    print("Error selecting file: \(error)")
                }
            }
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
            existingItem.setThumbnailImage(selectedImage)
            existingItem.setEmojiPlaceholder(selectedEmoji)
            existingItem.contextFlags = contextFlags
            
            // Update attachments - first remove all existing ones from the context
            for oldAttachment in existingItem.attachments {
                modelContext.delete(oldAttachment)
            }
            existingItem.attachments.removeAll()
            
            // Add new attachments
            for attachment in attachments {
                attachment.item = existingItem
                modelContext.insert(attachment)
                existingItem.attachments.append(attachment)
            }
        } else {
            // Create new item with the pre-generated UUID
            let newItem = Item(
                name: trimmedName,
                itemDescription: trimmedDescription,
                thumbnailData: nil,
                customFields: nil,
                tags: tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                emojiPlaceholder: selectedEmoji
            )
            
            // Override the auto-generated ID with our pre-generated one
            newItem.id = itemID
            newItem.contextFlags = contextFlags
            
            newItem.setThumbnailImage(selectedImage)
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
