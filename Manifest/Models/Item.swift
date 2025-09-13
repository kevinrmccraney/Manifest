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
    var lastViewedAt: Date? // Track when item was last viewed
    var viewCount: Int = 0 // Track how many times item has been viewed
    @Attribute(.externalStorage) var thumbnailData: Data?
    var customFields: Data?
    var tags: [String]
    var isArchived: Bool = false // New archive flag
    var emojiPlaceholder: String? // Optional emoji placeholder for this item
    var itemContext: Data? // Store context flags (fragile, heavy, etc.)
    
    // Computed property to get item context flags
    var contextFlags: ItemContextFlags {
        get {
            guard let data = itemContext,
                  let flags = try? JSONDecoder().decode(ItemContextFlags.self, from: data) else {
                return ItemContextFlags()
            }
            return flags
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                itemContext = data
                updateTimestamp()
            }
        }
    }
    
    // Multiple file attachments relationship
    @Relationship(deleteRule: .cascade, inverse: \FileAttachment.item)
    var attachments: [FileAttachment] = []
    
    // Keep legacy attachment properties for migration compatibility
    @Attribute(.externalStorage) var attachmentData: Data?
    var attachmentFilename: String?
    var attachmentDescription: String?
    
    init(name: String, itemDescription: String = "", thumbnailData: Data? = nil, customFields: Data? = nil, tags: [String] = [], attachmentData: Data? = nil, attachmentFilename: String? = nil, attachmentDescription: String? = nil, isArchived: Bool = false, emojiPlaceholder: String? = nil, itemContext: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastViewedAt = nil
        self.viewCount = 0
        self.thumbnailData = thumbnailData
        self.customFields = customFields
        self.tags = tags
        self.attachmentData = attachmentData
        self.attachmentFilename = attachmentFilename
        self.attachmentDescription = attachmentDescription
        self.attachments = []
        self.isArchived = isArchived
        self.emojiPlaceholder = emojiPlaceholder
        self.itemContext = itemContext
    }
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
    
    // Track when item is viewed
    func recordView() {
        lastViewedAt = Date()
        viewCount += 1
    }
    
    // Archive/Unarchive methods
    func archive() {
        isArchived = true
        updateTimestamp()
    }
    
    func unarchive() {
        isArchived = false
        updateTimestamp()
    }
    
    // MARK: - Computed Properties
    var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    // Get the emoji placeholder for this item, falling back to app default
    var effectiveEmojiPlaceholder: String {
        let result = emojiPlaceholder ?? AppSettings.shared.defaultEmojiPlaceholder
        //print("Getting effective emoji placeholder: \(result) (item emoji: \(String(describing: emojiPlaceholder)), default: \(AppSettings.shared.defaultEmojiPlaceholder))")
        return result
    }
    
    // Check if this item has a visual representation (either image or emoji)
    var hasVisualContent: Bool {
        return thumbnailData != nil || emojiPlaceholder != nil || !AppSettings.shared.defaultEmojiPlaceholder.isEmpty
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
    
    func setEmojiPlaceholder(_ emoji: String?) {
        emojiPlaceholder = emoji?.isEmpty == true ? nil : emoji
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
