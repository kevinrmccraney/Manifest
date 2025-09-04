//
//  SettingsView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = AppSettings.shared
    
    var body: some View {
        NavigationView {
            Form {
                // Display Settings Section
                Section(header: Text("Display")) {
                    // Default View Mode Setting
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text("Default View")
                        
                        Spacer()
                        
                        Picker("Default View", selection: $settings.defaultViewMode) {
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
                    
                    // Show Attachment Icons Setting
                    HStack {
                        Image(systemName: "paperclip")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text("Show Attachment Icons")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.showAttachmentIcons)
                    }
                }
                
                // About Section
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Manifest")
                                .font(.body)
                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}