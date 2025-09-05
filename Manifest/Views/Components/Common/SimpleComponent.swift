//
//  SimpleComponent.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-05.
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


struct SimplePicker: View {
    @Binding var selection: ViewMode
    var icon: String
    var labelText: String
    
    var body: some View {
        HStack {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
            }

            Text(labelText)

            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    HStack {
                        Image(systemName: mode.icon)
                        Text(mode.displayName)
                    }
                    .tag(mode)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}
