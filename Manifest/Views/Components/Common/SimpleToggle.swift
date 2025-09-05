//
//  SimpleToggle.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI

struct SimpleToggle: View {
    @Binding var isOn: Bool
    var icon: String
    var labelText: String
    
    var body: some View {
        HStack {
            Image(systemName: icon.isEmpty ? "circle" : icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
                .opacity(icon.isEmpty ? 0 : 1)
            
            Text(labelText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
    }
    
}
