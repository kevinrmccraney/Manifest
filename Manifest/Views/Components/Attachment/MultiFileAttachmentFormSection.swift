//
//  MultiFileAttachmentFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers
import PhotosUI

struct MultiFileAttachmentFormSection: View {
    @Binding var attachments: [FileAttachment]
    @State private var selectedFiles: [URL] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingDocumentPicker = false
    @State private var showingPhotosPicker = false
    @State private var showingCamera = false
    @State private var showingImageSourceActionSheet = false
    @State private var capturedImage: UIImage?
    @State private var previewAttachment: FileAttachment?
    @State private var shareURL: URL?
    
    var body: some View {
        Section(header: HStack {
            Text("File Attachments")
            .textCase(.uppercase)
            Spacer()
            Menu("Add Files") {
                Button("Files") {
                    showingDocumentPicker = true
                }
                Button("Photos") {
                    showingPhotosPicker = true
                }
                Button("Camera") {
                    showingCamera = true
                }
            }
            .font(.caption)
        }) {
            if attachments.isEmpty {
                Text("No files attached")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            } else {
                ForEach(attachments, id: \.id) { attachment in
                    FileAttachmentRow(
                        attachment: attachment,
                        onPreview: {
                            previewAttachment = attachment
                        },
                        onDownload: {
                            downloadFile(attachment)
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
        .onChange(of: selectedFiles) { _, newFiles in
            if !newFiles.isEmpty {
                processSelectedFiles(newFiles)
                selectedFiles = [] // Reset after processing
            }
        }
        .onChange(of: selectedPhotos) { _, newPhotos in
            if !newPhotos.isEmpty {
                processSelectedPhotos(newPhotos)
                selectedPhotos = [] // Reset after processing
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                processCapturedImage(image)
                capturedImage = nil // Reset after processing
            }
        }
        .background(
            DocumentPickerWrapper(
                isPresented: $showingDocumentPicker,
                selectedFiles: $selectedFiles
            )
        )
        .background(
            FilePreviewWrapper(
                attachment: $previewAttachment
            )
        )
        .background(
            ShareSheetWrapper(
                url: $shareURL
            )
        )
        .photosPicker(
            isPresented: $showingPhotosPicker,
            selection: $selectedPhotos,
            maxSelectionCount: 10, // Allow up to 10 photos at once
            matching: .images
        )
        .sheet(isPresented: $showingCamera) {
            ImagePicker(selectedImage: $capturedImage, sourceType: .camera)
        }
    }
    
    private func processSelectedFiles(_ urls: [URL]) {
        print("Processing \(urls.count) selected files")
        
        for fileURL in urls {
            do {
                // For document picker, files are already copied to app sandbox
                let fileData = try Data(contentsOf: fileURL)
                let mimeType = getMimeType(for: fileURL.pathExtension)
                
                // Create attachment
                let attachment = FileAttachment(
                    filename: fileURL.lastPathComponent,
                    fileDescription: fileURL.lastPathComponent,
                    fileData: fileData,
                    mimeType: mimeType
                )
                
                // Add to attachments array
                attachments.append(attachment)
                print("Successfully added file: \(fileURL.lastPathComponent), total attachments: \(attachments.count)")
                
            } catch {
                print("Error processing file \(fileURL.lastPathComponent): \(error)")
            }
        }
        
        print("Final attachment count after processing: \(attachments.count)")
    }
    
    private func processSelectedPhotos(_ photos: [PhotosPickerItem]) {
        print("Processing \(photos.count) selected photos")
        
        for photo in photos {
            Task {
                if let data = try? await photo.loadTransferable(type: Data.self) {
                    // Generate a filename with timestamp
                    let timestamp = DateFormatter().apply {
                        $0.dateFormat = "yyyyMMdd_HHmmss"
                    }.string(from: Date())
                    
                    let filename: String
                    if let identifier = photo.itemIdentifier {
                        // Try to extract original filename or create one
                        filename = "Photo_\(timestamp).jpg"
                    } else {
                        filename = "Photo_\(timestamp).jpg"
                    }
                    
                    await MainActor.run {
                        let attachment = FileAttachment(
                            filename: filename,
                            fileDescription: filename,
                            fileData: data,
                            mimeType: "image/jpeg"
                        )
                        
                        attachments.append(attachment)
                        print("Successfully added photo: \(filename), total attachments: \(attachments.count)")
                    }
                }
            }
        }
    }
    
    private func processCapturedImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error converting captured image to data")
            return
        }
        
        let timestamp = DateFormatter().apply {
            $0.dateFormat = "yyyyMMdd_HHmmss"
        }.string(from: Date())
        
        let filename = "Camera_\(timestamp).jpg"
        
        let attachment = FileAttachment(
            filename: filename,
            fileDescription: filename,
            fileData: imageData,
            mimeType: "image/jpeg"
        )
        
        attachments.append(attachment)
        print("Successfully added captured image: \(filename), total attachments: \(attachments.count)")
    }
    
    private func downloadFile(_ attachment: FileAttachment) {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
        
        do {
            try attachment.fileData.write(to: tempFileURL)
            shareURL = tempFileURL
        } catch {
            print("Error creating temp file for download: \(error)")
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
        case "heic": return "image/heic"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "mp3": return "audio/mpeg"
        case "wav": return "audio/wav"
        case "zip": return "application/zip"
        default: return "application/octet-stream"
        }
    }
}

// Extension to make DateFormatter configuration more readable
extension DateFormatter {
    func apply(closure: (DateFormatter) -> Void) -> DateFormatter {
        closure(self)
        return self
    }
}

// Wrapper views that handle presentations without interfering with parent sheets
struct DocumentPickerWrapper: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedFiles: [URL]
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented && uiViewController.presentedViewController == nil {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
                .data, .pdf, .image, .video, .audio, .text, .content, .item
            ], asCopy: true)
            picker.allowsMultipleSelection = true
            picker.delegate = context.coordinator
            
            DispatchQueue.main.async {
                uiViewController.present(picker, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerWrapper
        
        init(_ parent: DocumentPickerWrapper) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("Document picker selected \(urls.count) files")
            parent.selectedFiles = urls
            parent.isPresented = false
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
            parent.isPresented = false
        }
    }
}

struct FilePreviewWrapper: UIViewControllerRepresentable {
    @Binding var attachment: FileAttachment?
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let attachment = attachment, uiViewController.presentedViewController == nil {
            let previewController = createPreviewController(for: attachment)
            
            DispatchQueue.main.async {
                uiViewController.present(previewController, animated: true)
                self.attachment = nil // Reset after presenting
            }
        }
    }
    
    private func createPreviewController(for attachment: FileAttachment) -> UIViewController {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
        
        do {
            try attachment.fileData.write(to: tempFileURL)
            
            let previewController = QLPreviewController()
            previewController.dataSource = PreviewDataSource(url: tempFileURL)
            
            // Create navigation controller to wrap the preview controller
            let navigationController = UINavigationController(rootViewController: previewController)
            
            // Set up the navigation bar
            previewController.navigationItem.title = attachment.filename
            previewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Done",
                style: .done,
                target: previewController,
                action: #selector(QLPreviewController.dismissPreview)
            )
            
            return navigationController
        } catch {
            print("Error creating preview: \(error)")
            let errorController = UIViewController()
            errorController.view.backgroundColor = .systemBackground
            return errorController
        }
    }
    
    class PreviewDataSource: NSObject, QLPreviewControllerDataSource {
        let url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }
    }
}

// Extension to add the dismiss action
extension QLPreviewController {
    @objc func dismissPreview() {
        dismiss(animated: true)
    }
}

struct ShareSheetWrapper: UIViewControllerRepresentable {
    @Binding var url: URL?
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let url = url, uiViewController.presentedViewController == nil {
            let shareController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            DispatchQueue.main.async {
                uiViewController.present(shareController, animated: true)
                self.url = nil // Reset after presenting
            }
        }
    }
}
