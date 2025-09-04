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
            _attachmentDescription = State(initialValue: item.attachmentDescription ?? item.attachmentFilename ?? "")
            
            let fieldsDict = item.customFieldsDict
            _customFields = State(initialValue: fieldsDict.map { CustomField(key: $0.key, value: $0.value) })
        }
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
                
                FileAttachmentFormSection(
                    selectedFileURL: $selectedFileURL,
                    attachmentDescription: $attachmentDescription,
                    showingFilePicker: $showingFilePicker,
                    item: item
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
        let trimmedAttachmentDescription = attachmentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle file attachment
        var attachmentData: Data?
        var attachmentFilename: String?
        var finalAttachmentDescription: String?
        
        if let fileURL = selectedFileURL {
            do {
                attachmentData = try Data(contentsOf: fileURL)
                attachmentFilename = fileURL.lastPathComponent
                finalAttachmentDescription = trimmedAttachmentDescription.isEmpty ? attachmentFilename : trimmedAttachmentDescription
            } catch {
                print("Error reading file: \(error)")
            }
        } else if item?.attachmentData != nil && !attachmentDescription.isEmpty {
            // Keep existing attachment if no new file selected
            attachmentData = item?.attachmentData
            attachmentFilename = item?.attachmentFilename
            finalAttachmentDescription = trimmedAttachmentDescription
        }
        
        if let existingItem = item {
            // Edit existing item
            existingItem.name = trimmedName
            existingItem.itemDescription = trimmedDescription
            existingItem.tags = tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            existingItem.setThumbnailImage(selectedImage)
            
            // Handle attachment
            if selectedFileURL != nil || attachmentDescription.isEmpty {
                // New file selected or attachment being removed
                existingItem.setAttachment(data: attachmentData, filename: attachmentFilename, description: finalAttachmentDescription)
            } else {
                // Just updating description of existing attachment
                existingItem.attachmentDescription = finalAttachmentDescription
                existingItem.updateTimestamp()
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
            // Create new item
            let newItem = Item(
                name: trimmedName,
                itemDescription: trimmedDescription,
                thumbnailData: nil, // Will be set via setThumbnailImage
                customFields: nil, // Will be set via setCustomFields
                tags: tags.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
                attachmentData: attachmentData,
                attachmentFilename: attachmentFilename,
                attachmentDescription: finalAttachmentDescription
            )
            
            newItem.setThumbnailImage(selectedImage)
            
            // Save custom fields
            let fieldsDict = Dictionary(uniqueKeysWithValues:
                customFields
                    .filter { !$0.key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                    .map { ($0.key.trimmingCharacters(in: .whitespacesAndNewlines),
                           $0.value.trimmingCharacters(in: .whitespacesAndNewlines)) }
            )
            newItem.setCustomFields(fieldsDict)
            
            modelContext.insert(newItem)
        }
        
        dismiss()
    }
}
