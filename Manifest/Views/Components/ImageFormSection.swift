//
//  ImageFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ImageFormSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        Section(header: Text("Image")) {
            HStack {
                ImagePreview(image: selectedImage)
                
                ImageControls(
                    hasImage: selectedImage != nil,
                    onChooseImage: { showingActionSheet = true },
                    onRemoveImage: { selectedImage = nil }
                )
                
                Spacer()
            }
        }
    }
}
