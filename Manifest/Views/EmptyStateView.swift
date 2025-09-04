//
//  EmptyStateView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct EmptyStateView: View {
    @Binding var showingAddItem: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Items Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first item")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Add Item") {
                showingAddItem = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
