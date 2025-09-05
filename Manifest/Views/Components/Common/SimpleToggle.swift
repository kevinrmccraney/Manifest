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
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(labelText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
    }
    
}
