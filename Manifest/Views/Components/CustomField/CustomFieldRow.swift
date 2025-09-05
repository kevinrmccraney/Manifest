//
//  CustomFieldRow.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct CustomFieldRow: View {
    @Binding var customField: CustomField
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            TextField("Field Name", text: $customField.key)
                .textFieldStyle(.roundedBorder)
            
            TextField("Field Value", text: $customField.value, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
            
            HStack {
                Spacer()
                Button("Remove") {
                    onRemove()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}
