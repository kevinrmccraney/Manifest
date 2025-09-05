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
                Section(header: Text("Appearance")) {
                    // Default View Mode Setting
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text("Default View")
                        
                        Spacer()
                        
                        Picker("", selection: $settings.defaultViewMode) {
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
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "paperclip",
                        labelText: "Show Attachment Icons"
                    )
                    
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "",
                        labelText: "Show Tags outside Detailed Item View"
                    )
                    
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "",
                        labelText: "Show Description outside Detailed Item View"
                    )
                    
                    // Show Grid/List Toggle
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "grid",
                        labelText: "Show Grid/List Toggle"
                    )
                    
                }
                
                Section(header: Text("Functionality")) {

                    
                    // Show NFC Toggle
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "wave.3.right",
                        labelText: "Enable NFC"
                    )
                    
                    // Show QR Toggle
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "qrcode",
                        labelText: "Enable QR"
                    )
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
