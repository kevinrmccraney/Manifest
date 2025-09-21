//
//  AttachmentDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-21.
//

import SwiftUI

struct AttachmentDisplayView: View {
    let attachments: [FileAttachment]
    let displayStyle: DisplayStyle
    @State private var showingPreview = false
    @State private var previewStartIndex = 0
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    @State private var showingDownloadMenu = false
    @State private var selectedAttachment: FileAttachment?
    
    enum DisplayStyle {
        case detail      // For ItemDetailView (full display)
        case form        // For AddEditItemView (with edit controls)
        case inline      // For list/grid views (minimal)
    }
    
    var body: some View {
        if attachments.isEmpty {
            EmptyView()
        } else {
            switch displayStyle {
            case .detail:
                detailView
            case .form:
                formView
            case .inline:
                inlineView
            }
        }
    }
    
    // MARK: - Detail View (ItemDetailView)
    
    @ViewBuilder
    private var detailView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Attachments (\(attachments.count))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            ForEach(Array(attachments.enumerated()), id: \.element.id) { index, attachment in
                AttachmentRowView(
                    attachment: attachment,
                    showPreview: true,
                    onPreviewTap: {
                        previewStartIndex = index
                        showingPreview = true
                    },
                    onDownload: {
                        selectedAttachment = attachment
                        showingDownloadMenu = true
                    }
                )
            }
        }
        .sheet(isPresented: $showingPreview) {
            MultiFilePreviewView(attachments: attachments, initialIndex: previewStartIndex)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ActivityViewController(activityItems: [url])
            }
        }
        .confirmationDialog("File Options", isPresented: $showingDownloadMenu) {
            Button("Download") {
                if let attachment = selectedAttachment {
                    downloadFile(attachment)
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Form View (AddEditItemView)
    
    @ViewBuilder
    private var formView: some View {
        ForEach(attachments, id: \.id) { attachment in
            FileAttachmentEditRow(
                attachment: attachment,
                attachments: attachments,
                onDownload: {
                    downloadFile(attachment)
                },
                onDelete: {
                    // This would need to be passed in as a closure
                }
            )
        }
    }
    
    // MARK: - Inline View (List/Grid views)
    
    @ViewBuilder
    private var inlineView: some View {
        HStack(spacing: 2) {
            Image(systemName: "doc.fill")
                .foregroundStyle(.white)
                .font(.caption)
            
            if attachments.count > 1 {
                Text("\(attachments.count)")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.6))
        .cornerRadius(4)
    }
    
    // MARK: - Helper Views
    
    private struct AttachmentRowView: View {
        let attachment: FileAttachment
        let showPreview: Bool
        let onPreviewTap: () -> Void
        let onDownload: () -> Void
        
        var body: some View {
            HStack {
                // Icon or image preview
                if attachment.isImage, let image = UIImage(data: attachment.fileData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipped()
                        .cornerRadius(6)
                } else {
                    Image(systemName: attachment.fileIcon)
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    if showPreview {
                        Button(attachment.fileDescription) {
                            onPreviewTap()
                        }
                        .font(.body)
                        .foregroundStyle(.primary)
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text(attachment.fileDescription)
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                    
                    Text(attachment.formattedFileSize)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: onDownload) {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func downloadFile(_ attachment: FileAttachment) {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
        
        do {
            try attachment.fileData.write(to: tempFileURL)
            shareURL = tempFileURL
            showingShareSheet = true
        } catch {
            print("Error creating temp file for download: \(error)")
        }
    }
}
