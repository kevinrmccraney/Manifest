//
//  FileAttachmentManager.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-17.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

class FileAttachmentManager: ObservableObject {
    @Published var showingDocumentPicker = false
    @Published var showingPhotosPicker = false
    @Published var showingCamera = false
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var capturedImage: UIImage?
    @Published var previewAttachment: FileAttachment?
    @Published var shareItem: ShareItem?
    @Published var newAttachments: [FileAttachment] = []
    
    init() {
        // Watch for photo selection changes
        $selectedPhotos
            .removeDuplicates()
            .sink { [weak self] photos in
                if !photos.isEmpty {
                    Task {
                        await self?.processSelectedPhotos(photos)
                        await MainActor.run {
                            self?.selectedPhotos = []
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // Watch for captured image changes
        $capturedImage
            .compactMap { $0 }
            .sink { [weak self] image in
                self?.processCapturedImage(image)
                self?.capturedImage = nil
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func showDocumentPicker() {
        showingDocumentPicker = true
    }
    
    func showPhotosPicker() {
        showingPhotosPicker = true
    }
    
    func showCamera() {
        showingCamera = true
    }
    
    func downloadFile(_ attachment: FileAttachment) {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
        
        do {
            try attachment.fileData.write(to: tempFileURL)
            shareItem = ShareItem(url: tempFileURL)
        } catch {
            print("Error creating temp file for download: \(error)")
        }
    }
    
    func clearNewAttachments() {
        newAttachments.removeAll()
    }
    
    func handleDocumentPickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            processSelectedFiles(urls)
        case .failure(let error):
            print("Document picker error: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func processSelectedFiles(_ urls: [URL]) {
        print("Processing \(urls.count) selected files")
        
        var processedAttachments: [FileAttachment] = []
        
        for fileURL in urls {
            do {
                let fileData = try Data(contentsOf: fileURL)
                let mimeType = FileTypeHelper.getMimeType(for: fileURL.pathExtension)
                
                let attachment = FileAttachment(
                    filename: fileURL.lastPathComponent,
                    fileDescription: fileURL.lastPathComponent,
                    fileData: fileData,
                    mimeType: mimeType
                )
                
                processedAttachments.append(attachment)
                print("Processed file: \(fileURL.lastPathComponent)")
                
            } catch {
                print("Error processing file \(fileURL.lastPathComponent): \(error)")
            }
        }
        
        DispatchQueue.main.async {
            self.newAttachments.append(contentsOf: processedAttachments)
            print("Added \(processedAttachments.count) file attachments")
        }
    }
    
    private func processSelectedPhotos(_ photos: [PhotosPickerItem]) async {
        print("Processing \(photos.count) selected photos")
        
        var processedAttachments: [FileAttachment] = []
        
        for (index, photo) in photos.enumerated() {
            do {
                if let data = try await photo.loadTransferable(type: Data.self) {
                    let filename = FileNameHelper.generatePhotoFilename(index: index)
                    
                    let attachment = FileAttachment(
                        filename: filename,
                        fileDescription: filename,
                        fileData: data,
                        mimeType: "image/jpeg"
                    )
                    
                    processedAttachments.append(attachment)
                    print("Processed photo: \(filename)")
                }
            } catch {
                print("Error processing photo \(index): \(error)")
            }
        }
        
        await MainActor.run {
            self.newAttachments.append(contentsOf: processedAttachments)
            print("Added \(processedAttachments.count) photo attachments")
        }
    }
    
    private func processCapturedImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error converting captured image to data")
            return
        }
        
        let filename = FileNameHelper.generateCameraFilename()
        
        let attachment = FileAttachment(
            filename: filename,
            fileDescription: filename,
            fileData: imageData,
            mimeType: "image/jpeg"
        )
        
        newAttachments.append(attachment)
        print("Added captured image: \(filename)")
    }
}

// MARK: - Helper Classes

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct FileTypeHelper {
    static func getMimeType(for fileExtension: String) -> String {
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

struct FileNameHelper {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
    
    static func generatePhotoFilename(index: Int) -> String {
        let timestamp = dateFormatter.string(from: Date())
        return "Photo_\(timestamp)_\(index).jpg"
    }
    
    static func generateCameraFilename() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return "Camera_\(timestamp).jpg"
    }
}

import Combine
