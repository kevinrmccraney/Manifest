//
//  CustomFieldsFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct CustomFieldsFormSection: View {
    @Binding var customFields: [CustomField]
    
    var body: some View {
        Section(header: HStack {
            Text("Custom Fields")
            Spacer()
            Button("Add Field") {
                customFields.append(CustomField(key: "", value: ""))
            }
            .font(.caption)
        }) {
            if customFields.isEmpty {
                Text("No custom fields added")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                ForEach(customFields.indices, id: \.self) { index in
                    CustomFieldRow(
                        customField: $customFields[index],
                        onRemove: {
                            customFields.remove(at: index)
                        }
                    )
                }
            }
        }
    }
}
