//
//  ItemDetailsWithEmojiFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ItemDetailsWithEmojiFormSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var selectedEmoji: String?
    let onEmojiTapped: () -> Void
    @State private var isEmojiButtonPressed = false
    
    var body: some View {
        Section(header: Text("Item Details")) {
            // Name field with emoji picker
            HStack(spacing: 12) {
                // Emoji picker button with visual feedback
                Button(action: onEmojiTapped) {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.blue.opacity(0.3), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                                .scaleEffect(isEmojiButtonPressed ? 0.95 : 1.0)
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(selectedEmoji ?? AppSettings.shared.defaultEmojiPlaceholder)
                                .font(.system(size: 24))
                        )
                        .animation(.easeInOut(duration: 0.1), value: isEmojiButtonPressed)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isEmojiButtonPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isEmojiButtonPressed = pressing
                }, perform: {})
                
                VStack(spacing: 4) {
                    // Name field with clear button
                    HStack {
                        TextField("Name", text: $name)
                            .font(.body)
                        
                        if !name.isEmpty {
                            Button(action: {
                                name = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    HStack {
                        if selectedEmoji != nil {
                            Button("Use Default") {
                                selectedEmoji = nil
                            }
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        } else {
                            Text("Using app default emoji")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            TextField("Description", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}
