//
//  EmojiFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-09.
//

import SwiftUI

struct EmojiFormSection: View {
    @Binding var selectedEmoji: String?
    @State private var showingEmojiSheet = false
    
    var body: some View {
        Section(header: Text("Emoji")) {
            HStack {
                // Show current emoji or default
                Text(selectedEmoji ?? AppSettings.shared.defaultEmojiPlaceholder)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Button("Choose Emoji") {
                        showingEmojiSheet = true
                    }
                    .buttonStyle(.bordered)
                    
                    if selectedEmoji != nil {
                        Button("Use Default") {
                            selectedEmoji = nil
                        }
                        .foregroundStyle(.orange)
                        .font(.caption)
                    }
                    
                    if selectedEmoji == nil {
                        Text("Using app default: \(AppSettings.shared.defaultEmojiPlaceholder)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Custom emoji set")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingEmojiSheet) {
            EmojiPickerSheet(selectedEmoji: $selectedEmoji)
        }
    }
}

struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String?
    @Environment(\.dismiss) private var dismiss
    @State private var emojiInput = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Choose Emoji")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Large emoji preview
                Text(emojiInput.isEmpty ? (selectedEmoji ?? "📦") : emojiInput)
                    .font(.system(size: 100))
                    .frame(height: 120)
                
                VStack(spacing: 16) {
                    Text("Tap the text field below and use your emoji keyboard")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    TextField("Select an emoji", text: $emojiInput)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .focused($isTextFieldFocused)
                        .onChange(of: emojiInput) { oldValue, newValue in
                            // Keep only the last character if it's an emoji
                            if let lastChar = newValue.last, lastChar.isEmoji {
                                emojiInput = String(lastChar)
                            } else if !newValue.isEmpty {
                                // If not an emoji, revert to previous value or clear
                                emojiInput = oldValue.isEmpty ? "" : oldValue
                            }
                        }
                    
                    Button("Save Emoji") {
                        if !emojiInput.isEmpty {
                            selectedEmoji = emojiInput
                            print("Saved emoji: \(emojiInput)")
                        }
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(emojiInput.isEmpty)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Emoji Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                emojiInput = selectedEmoji ?? ""
                // Delay focusing to ensure proper keyboard appearance
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

// Improved emoji detection
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value >= 0x1F600 || unicodeScalars.count > 1)
    }
}
