//
//  ImageControls.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ImageControls: View {
    let hasImage: Bool
    let onChooseImage: () -> Void
    let onRemoveImage: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Choose Image") {
                onChooseImage()
            }
            .buttonStyle(.bordered)
            
            if hasImage {
                Button("Remove Image") {
                    onRemoveImage()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
        }
    }
}
