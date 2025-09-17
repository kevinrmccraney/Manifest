//
//  FileAttachment.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import Foundation
import SwiftData

@Model
final class FileAttachment {
    var id: UUID
    var filename: String
    var fileDescription: String
    @Attribute(.externalStorage) var fileData: Data
    var mimeType: String
    var fileSize: Int64
    var createdAt: Date
    
    // Relationship back to Item
    var item: Item?
    
    init(filename: String, fileDescription: String, fileData: Data, mimeType: String) {
        self.id = UUID()
        self.filename = filename
        self.fileDescription = fileDescription.isEmpty ? filename : fileDescription
        self.fileData = fileData
        self.mimeType = mimeType
        self.fileSize = Int64(fileData.count)
        self.createdAt = Date()
    }
    
    var fileExtension: String {
        (filename as NSString).pathExtension.lowercased()
    }
    
    var fileIcon: String {
        switch fileExtension {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.fill.on.rectangle.fill"
        case "txt": return "doc.text"
        case "jpg", "jpeg", "png", "gif", "heic", "webp": return "photo.fill"
        case "mp4", "mov", "avi", "mkv", "webm": return "video.fill"
        case "mp3", "wav", "m4a", "aac", "flac": return "music.note"
        case "zip", "rar", "7z", "tar", "gz": return "archivebox.fill"
        case "sketch": return "paintbrush.fill"
        case "figma": return "rectangle.3.group.fill"
        case "ai", "eps": return "triangle.fill"
        case "psd": return "square.stack.3d.up.fill"
        default: return "doc.fill"
        }
    }
    
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "heic", "webp", "bmp", "tiff"]
        return imageExtensions.contains(fileExtension)
    }
    
    var isVideo: Bool {
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "webm", "m4v", "3gp"]
        return videoExtensions.contains(fileExtension)
    }
    
    var isAudio: Bool {
        let audioExtensions = ["mp3", "wav", "m4a", "aac", "flac", "ogg"]
        return audioExtensions.contains(fileExtension)
    }
    
    var isDocument: Bool {
        let documentExtensions = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf"]
        return documentExtensions.contains(fileExtension)
    }
    
    var fileType: FileType {
        if isImage { return .image }
        if isVideo { return .video }
        if isAudio { return .audio }
        if isDocument { return .document }
        return .other
    }
    
    enum FileType: String, CaseIterable {
        case image = "Image"
        case video = "Video"
        case audio = "Audio"
        case document = "Document"
        case other = "File"
        
        var icon: String {
            switch self {
            case .image: return "photo.fill"
            case .video: return "video.fill"
            case .audio: return "music.note"
            case .document: return "doc.fill"
            case .other: return "doc.fill"
            }
        }
        
        var color: String {
            switch self {
            case .image: return "green"
            case .video: return "blue"
            case .audio: return "purple"
            case .document: return "orange"
            case .other: return "gray"
            }
        }
    }
}
