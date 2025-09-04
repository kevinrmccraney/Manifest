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
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var customFields: [CustomField] = []
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var attachments: [FileAttachment] = []
    @State private var itemID: UUID = UUID() // Create UUID immediately
    
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
            _tags = State(initialValue: item.tags)
            _attachments = State(initialValue: item.attachments)
            _attachmentDescription = State(initialValue: item.attachmentDescription ?? item.attachmentFilename ?? "")
            _itemID = State(initialValue: item.id) // Use existing ID for editing
            
            let fieldsDict = item.customFieldsDict
            _customFields = State(initialValue: fieldsDict.map { CustomField(key: $0.key, value: $0.value) })
        }
        // For new items, itemID is already initialized with UUID()
    }
    
    var body: some View {
        NavigationView {
            Form {
                ItemDetailsFormSection(
                    name: $name,
                    description: $description
                )
                
                TagsFormSection(
                    tags: $tags,
                    newTag: $newTag
                )
                
                ImageFormSection(
                    selectedImage: $selectedImage,
                    showingActionSheet: $showingActionSheet
                )
                
                MultiFileAttachmentFormSection(attachments: $attachments)
                
                QRCodeGeneratorSection(
                    item: item,
                    itemName: name.isEmpty ? "Untitled Item" : name,
                    itemID: itemID,
                    attachments: $attachments
                )
                
                CustomFieldsFormSection(customFields: $customFields)
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
        for (index, attachment) in attachments.enumerated() {
            print("Attachment \(index): \(attachment.filename) (ID: \(attachment.id))")
        }
        
        if let existingItem = item {
            // Edit existing item
            existingItem.name = trimmedName
            existingItem.itemDescription = trimmedDescription
            existingItem.tags = tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            existingItem.setThumbnailImage(selectedImage)
            
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
            
            // Save custom fields
            let fieldsDict = Dictionary(uniqueKeysWithValues:
                customFields
                    .filter { !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .map { ($0.key.trimmingCharacters(in: .whitespacesAndNewlines),
                           $0.value.trimmingCharacters(in: .whitespacesAndNewlines)) }
            )
            existingItem.setCustomFields(fieldsDict)
        } else {
            // Create new item with the pre-generated UUID
            let newItem = Item(
                name: trimmedName,
                itemDescription: trimmedDescription,
                thumbnailData: nil,
                customFields: nil,
                tags: tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            )
            
            // Override the auto-generated ID with our pre-generated one
            newItem.id = itemID
            
            newItem.setThumbnailImage(selectedImage)
            
            // Save custom fields
            let fieldsDict = Dictionary(uniqueKeysWithValues:
                customFields
                    .filter { !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .map { ($0.key.trimmingCharacters(in: .whitespacesAndNewlines),
                           $0.value.trimmingCharacters(in: .whitespacesAndNewlines)) }
            )
            newItem.setCustomFields(fieldsDict)
            
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
