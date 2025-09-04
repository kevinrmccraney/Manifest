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
        case "jpg", "jpeg", "png", "gif", "heic": return "photo.fill"
        case "mp4", "mov", "avi": return "video.fill"
        case "mp3", "wav", "m4a": return "music.note"
        case "zip", "rar": return "archivebox.fill"
        default: return "doc.fill"
        }
    }
    
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
}
