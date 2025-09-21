//
//  ImageHandler.swift
//  Manifest
//
//  Centralized image processing and utilities
//

import SwiftUI
import UIKit

struct ImageHandler {
    
    // MARK: - Image Processing
    
    static func resizeImage(_ image: UIImage, to size: CGSize, quality: CGFloat = 0.8) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resizedImage.jpegData(compressionQuality: quality)
    }
    
    static func createThumbnail(from image: UIImage, size: CGFloat = 100) -> Data? {
        return resizeImage(image, to: CGSize(width: size, height: size))
    }
    
    // MARK: - Image Source Selection
    
    enum ImageSource {
        case camera
        case photoLibrary
        case files
    }
    
    static func presentImageSourceSelection(
        availableSources: [ImageSource] = [.camera, .photoLibrary, .files],
        onSelection: @escaping (ImageSource) -> Void
    ) -> ActionSheet {
        var buttons: [ActionSheet.Button] = []
        
        if availableSources.contains(.camera) {
            buttons.append(.default(Text("Camera")) {
                onSelection(.camera)
            })
        }
        
        if availableSources.contains(.photoLibrary) {
            buttons.append(.default(Text("Photo Library")) {
                onSelection(.photoLibrary)
            })
        }
        
        if availableSources.contains(.files) {
            buttons.append(.default(Text("Files")) {
                onSelection(.files)
            })
        }
        
        buttons.append(.cancel())
        
        return ActionSheet(
            title: Text("Select Image Source"),
            buttons: buttons
        )
    }
    
    // MARK: - Image Display Helpers
    
    @ViewBuilder
    static func makeImageThumbnail(
        image: UIImage?,
        emoji: String?,
        size: CGFloat,
        cornerRadius: CGFloat = 8
    ) -> some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipped()
                .cornerRadius(cornerRadius)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.gray.opacity(0.1))
                .frame(width: size, height: size)
                .overlay(
                    Text(emoji ?? AppSettings.shared.defaultEmojiPlaceholder)
                        .font(.system(size: size * 0.6))
                )
        }
    }
}
