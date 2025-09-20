//
//  FileAttachmentSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI

struct FileAttachmentSection: View {
    @Binding var attachments: [FileAttachment]
    @Bindable var item: Item
    @StateObject private var fileManager = FileAttachmentManager()
    let onThumbnailSelected: ((UIImage?) -> Void)?
    let onEmojiSelected: ((String?) -> Void)?
    
    // This computed property will re-evaluate when attachments binding changes
    private var hasImageAttachments: Bool {
        let imageCount = attachments.filter { $0.isImage }.count
        print("FileAttachmentSection: hasImageAttachments check - total: \(attachments.count), images: \(imageCount)")
        return imageCount > 0
    }
    
    var body: some View {
        Section(header: HStack {
            Text("File Attachments")
                .textCase(.uppercase)
            Spacer()
            HStack(spacing: 12) {
                FileAttachmentMenu(fileManager: fileManager)
            }
        }) {
            if attachments.isEmpty {
                Text("No files attached")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                ForEach(attachments, id: \.id) { attachment in
                    FileAttachmentEditRow(
                        attachment: attachment,
                        attachments: attachments,
                        onDownload: {
                            fileManager.downloadFile(attachment)
                        },
                        onDelete: {
                            deleteAttachment(attachment)
                        }
                    )
                }
            }
        }
        .onReceive(fileManager.$newAttachments) { newAttachments in
            if !newAttachments.isEmpty {
                print("Adding \(newAttachments.count) new attachments to existing \(attachments.count)")
                attachments.append(contentsOf: newAttachments)
                print("Total attachments after adding: \(attachments.count)")
                print("Image attachments available: \(attachments.filter { $0.isImage }.count)")
                fileManager.clearNewAttachments()
            }
        }
        .sheet(item: $fileManager.shareItem) { item in
            ActivityViewController(activityItems: [item.url])
        }
    }
    
    private func deleteAttachment(_ attachment: FileAttachment) {
        attachments.removeAll { $0.id == attachment.id }
        print("Deleted attachment: \(attachment.filename), remaining: \(attachments.count)")
    }
}
