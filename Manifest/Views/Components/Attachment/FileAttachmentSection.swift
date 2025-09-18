//
//  FileAttachmentSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI

struct FileAttachmentSection: View {
    @Binding var attachments: [FileAttachment]
    @StateObject private var fileManager = FileAttachmentManager()
    
    var body: some View {
        Section(header: HStack {
            Text("File Attachments")
                .textCase(.uppercase)
            Spacer()
            FileAttachmentMenu(fileManager: fileManager)
        }) {
            if attachments.isEmpty {
                Text("No files attached")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                ForEach(attachments, id: \.id) { attachment in
                    FileAttachmentEditRow(
                        attachment: attachment,
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
