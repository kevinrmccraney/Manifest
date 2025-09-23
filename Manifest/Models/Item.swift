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
    var isArchived: Bool = false // Archive flag
    var isPinned: Bool = false // Pin flag
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
    
    init(name: String, itemDescription: String = "", thumbnailData: Data? = nil, customFields: Data? = nil, tags: [String] = [], isArchived: Bool = false, isPinned: Bool = false, emojiPlaceholder: String? = nil, itemContext: Data? = nil) {
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
        self.attachments = []
        self.isArchived = isArchived
        self.isPinned = isPinned
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
        
    func togglePin() {
        isPinned.toggle()
        updateTimestamp()
    }

    func toggleArchive() {
        isArchived.toggle()
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
    
    // Check if item has any attachments
    var hasAnyAttachment: Bool {
        return !attachments.isEmpty
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
