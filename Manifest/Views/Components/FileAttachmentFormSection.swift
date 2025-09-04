//
//  FileAttachmentFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct FileAttachmentFormSection: View {
    @Binding var selectedFileURL: URL?
    @Binding var attachmentDescription: String
    @Binding var showingFilePicker: Bool
    let item: Item?
    
    var body: some View {
        Section(header: Text("File Attachment")) {
            if let fileURL = selectedFileURL {
                NewFileAttachmentView(
                    fileURL: fileURL,
                    attachmentDescription: $attachmentDescription,
                    onChangeFile: { showingFilePicker = true },
                    onRemoveFile: {
                        selectedFileURL = nil
                        attachmentDescription = ""
                    }
                )
            } else if item?.attachmentData != nil {
                ExistingFileAttachmentView(
                    item: item!,
                    attachmentDescription: $attachmentDescription,
                    onReplaceFile: { showingFilePicker = true },
                    onRemoveFile: {
                        selectedFileURL = nil
                        attachmentDescription = ""
                    }
                )
            } else {
                Button("Add File") {
                    showingFilePicker = true
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
