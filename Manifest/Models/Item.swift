//
//  Models.swift
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
    @Attribute(.externalStorage) var thumbnailData: Data?
    var customFields: Data?
    
    init(name: String, itemDescription: String = "", thumbnailData: Data? = nil, customFields: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.itemDescription = itemDescription
        self.createdAt = Date()
        self.thumbnailData = thumbnailData
        self.customFields = customFields
    }
    
    // MARK: - Computed Properties
    var thumbnailImage: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    func setThumbnailImage(_ image: UIImage?) {
        guard let image = image else {
            thumbnailData = nil
            return
        }
        
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        thumbnailData = resizedImage.jpegData(compressionQuality: 0.8)
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
            return
        }
        customFields = data
    }
}
