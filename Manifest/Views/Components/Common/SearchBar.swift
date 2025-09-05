//
//  SearchBar.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .trailing) {
                TextField("Search items...", text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .padding(.trailing, text.isEmpty ? 0 : 28) // Add padding when clear button is visible
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Clear button inside the text field
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 8)
                }
            }
        }
        .padding(.bottom, 8) // Add spacing below search bar
    }
}
