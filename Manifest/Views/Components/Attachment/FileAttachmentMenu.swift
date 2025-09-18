//
//  FileAttachmentMenu.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI

struct FileAttachmentMenu: View {
    @ObservedObject var fileManager: FileAttachmentManager
    
    var body: some View {
        Menu {
            Button(action: {
                fileManager.showDocumentPicker()
            }) {
                Label("Files", systemImage: "doc.fill")
            }
            
            Button(action: {
                fileManager.showPhotosPicker()
            }) {
                Label("Photos", systemImage: "photo.fill")
            }
            
            Button(action: {
                fileManager.showCamera()
            }) {
                Label("Camera", systemImage: "camera.fill")
            }
        } label: {
            Label("Add Files", systemImage: "plus.circle.fill")
                .font(.caption)
                .foregroundStyle(.blue)
        }
        .fileImporter(
            isPresented: $fileManager.showingDocumentPicker,
            allowedContentTypes: [.data, .pdf, .image, .video, .audio, .text, .content, .item],
            allowsMultipleSelection: true
        ) { result in
            fileManager.handleDocumentPickerResult(result)
        }
        .photosPicker(
            isPresented: $fileManager.showingPhotosPicker,
            selection: $fileManager.selectedPhotos,
            maxSelectionCount: 10,
            matching: .images
        )
        .sheet(isPresented: $fileManager.showingCamera) {
            ImagePicker(selectedImage: $fileManager.capturedImage, sourceType: .camera)
        }
    }
}
