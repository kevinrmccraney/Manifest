//
//  MultiFileAttachmentFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//


//
//  MultiFileAttachmentFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import QuickLook

struct MultiFileAttachmentFormSection: View {
    @Binding var attachments: [FileAttachment]
    @State private var showingFilePicker = false
    @State private var previewAttachment: FileAttachment?
    @State private var showingPreview = false
    
    var body: some View {
        Section(header: HStack {
            Text("File Attachments")
            Spacer()
            Button("Add Files") {
                showingFilePicker = true
            }
            .font(.caption)
        }) {
            if attachments.isEmpty {
                Text("No files attached")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(attachments, id: \.id) { attachment in
                    FileAttachmentRow(
                        attachment: attachment,
                        onPreview: {
                            previewAttachment = attachment
                            showingPreview = true
                        },
                        onDelete: {
                            if let index = attachments.firstIndex(where: { $0.id == attachment.id }) {
                                attachments.remove(at: index)
                            }
                        }
                    )
                }
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item], // Allows all file types
            allowsMultipleSelection: true // Enable multiple selection
        ) { result in
            do {
                let selectedFiles = try result.get()
                for fileURL in selectedFiles {
                    guard fileURL.startAccessingSecurityScopedResource() else { continue }
                    defer { fileURL.stopAccessingSecurityScopedResource() }
                    
                    let fileData = try Data(contentsOf: fileURL)
                    let mimeType = getMimeType(for: fileURL.pathExtension)
                    
                    let attachment = FileAttachment(
                        filename: fileURL.lastPathComponent,
                        fileDescription: fileURL.lastPathComponent,
                        fileData: fileData,
                        mimeType: mimeType
                    )
                    
                    attachments.append(attachment)
                }
            } catch {
                print("Error selecting files: \(error)")
            }
        }
        .sheet(isPresented: $showingPreview) {
            if let attachment = previewAttachment {
                FilePreviewView(fileAttachment: attachment)
            }
        }
    }
    
    private func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "ppt": return "application/vnd.ms-powerpoint"
        case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "txt": return "text/plain"
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "gif": return "image/gif"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "zip": return "application/zip"
        default: return "application/octet-stream"
        }
    }
}