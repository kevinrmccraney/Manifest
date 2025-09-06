//
//  SimpleComponent.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-05.
//

import SwiftUI

//
//  SimpleToggle.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SimpleToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let labelText: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            
            Text(labelText)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
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
