//
//  Item.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//
import Foundation
import SwiftData
import UIKit

@Model
final class Item {
    var id: UUID
    var name: String
    var itemDescription: String
    var createdAt: Date
    var updatedAt: Date
    @Attribute(.externalStorage) var thumbnailData: Data?
    var customFields: Data?
    var tags: [String]
    
    // Multiple file attachments relationship
    @Relationship(deleteRule: .cascade, inverse: \FileAttachment.item)
    var attachments: [FileAttachment] = []
    
    // Keep legacy attachment properties for migration compatibility
    @Attribute(.externalStorage) var attachmentData: Data?
    var attachmentFilename: String?
    var attachmentDescription: String?
    
    init(name: String, itemDescription: String = "", thumbnailData: Data? = nil, customFields: Data? = nil, tags: [String] = [], attachmentData: Data? = nil, attachmentFilename: String? = nil, attachmentDescription: String? = nil) {
        self.id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.thumbnailData = thumbnailData
        self.customFields = customFields
        self.tags = tags
        self.attachmentData = attachmentData
        self.attachmentFilename = attachmentFilename
        self.attachmentDescription = attachmentDescription
        self.attachments = []
    }
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    func setThumbnailImage(_ image: UIImage?) {
        guard let image = image else {
            thumbnailData = nil
            updateTimestamp()
            return
        }
        
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        thumbnailData = resizedImage.jpegData(compressionQuality: 0.8)
        updateTimestamp()
    }
    
    var customFieldsDict: [String: String] {
        guard let data = customFields,
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return [:]
        }
        return dict
    }
    
    func setCustomFields(_ fields: [String: String]) {
        guard let data = try? JSONSerialization.data(withJSONObject: fields) else {
            customFields = nil
            updateTimestamp()
            return
        }
        customFields = data
        updateTimestamp()
    }
    
    // Legacy attachment support - check both new and old systems
    var hasAnyAttachment: Bool {
        return !attachments.isEmpty || attachmentData != nil
    }
    
    // Legacy methods for backward compatibility
    func setAttachment(data: Data?, filename: String?, description: String?) {
        attachmentData = data
        attachmentFilename = filename
        attachmentDescription = description
        updateTimestamp()
    }
    
    var fileExtension: String {
        guard let filename = attachmentFilename else { return "" }
        return (filename as NSString).pathExtension.lowercased()
    }
    
    var fileIcon: String {
        // Check new attachments first
        if !attachments.isEmpty {
            return attachments.first?.fileIcon ?? "doc.fill"
        }
        
        // Fall back to legacy attachment
        switch fileExtension {
        case "pdf": return "doc.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.fill.on.rectangle.fill"
        case "txt": return "doc.text"
        case "jpg", "jpeg", "png", "gif": return "photo.fill"
        case "mp4", "mov", "avi": return "video.fill"
        case "mp3", "wav", "m4a": return "music.note"
        case "zip", "rar": return "archivebox.fill"
        default: return "doc.fill"
        }
    }
    
    // Add attachment method
    func addAttachment(_ attachment: FileAttachment) {
        attachments.append(attachment)
        updateTimestamp()
    }
    
    // Remove attachment method
    func removeAttachment(_ attachment: FileAttachment) {
        attachments.removeAll { $0.id == attachment.id }
        updateTimestamp()
    }
}
