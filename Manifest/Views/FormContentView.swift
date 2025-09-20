//
//  FormContentView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-19.
//


//
//  FormContentView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI

struct FormContentView: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedEmoji: String?
    @Binding var tags: [String]
    @Binding var newTag: String
    @Binding var contextFlags: ItemContextFlags
    @Binding var attachments: [FileAttachment]
    @Binding var showingThumbnailPicker: Bool
    
    let item: Item?
    let tempItem: Item?
    let editableItem: Item
    let updateTempItemAttachments: () -> Void
    
    // QR/NFC related
    let enabledNFCScanning: Bool
    let enabledQRScanning: Bool
    @Binding var showingNFCWriter: Bool
    let itemID: UUID
    
    var body: some View {
        Form {
            ItemDetailsWithEmojiFormSection(
                name: $name,
                description: $description,
                selectedEmoji: $selectedEmoji,
                onEmojiTapped: {
                    showingThumbnailPicker = true
                },
                item: item
            )
            
            TagsFormSection(
                tags: $tags,
                newTag: $newTag
            )
            
            ContextFormSection(contextFlags: $contextFlags)
            
            AttachmentSectionWrapper(
                attachments: $attachments,
                selectedEmoji: $selectedEmoji,
                item: item,
                tempItem: tempItem,
                editableItem: editableItem,
                updateTempItemAttachments: updateTempItemAttachments
            )
            
            if enabledQRScanning || enabledNFCScanning {
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
}