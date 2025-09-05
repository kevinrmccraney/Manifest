//
//  CustomFieldDisplayView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct CustomFieldsDisplayView: View {
    let customFields: [String: String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(customFields.keys.sorted()), id: \.self) { key in
                if let value = customFields[key], !value.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(key)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Text(value)
                            .font(.body)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}
