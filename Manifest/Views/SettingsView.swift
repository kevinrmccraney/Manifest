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
                Section(header: Text("Functionality")) {
                    SimpleToggle(
                        isOn: $settings.debugMode,
                        icon: "wrench",
                        labelText: "Debug Mode"
                    )
                }
                
                // Display Settings Section
                Section(header: Text("Appearance")) {
                    SimpleToggle(
                        isOn: $settings.showViewToggle,
                        icon: "grid",
                        labelText: "Show Grid/List Toggle"
                    )

                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "paperclip",
                        labelText: "Show Attachment Icons"
                    )
                }
                
                Section(header: Text("Sorting")) {
                    SimpleToggle(
                        isOn: $settings.showSortPicker,
                        icon: "arrow.up.arrow.down",
                        labelText: "Show Sorting Options"
                    )
                    
                    // Default Sort Order Setting
                    HStack {
                        Image(systemName: "list.number")
                            .foregroundStyle(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text("Default Sort Order")
                        
                        Spacer()
                        
                        Picker("", selection: $settings.defaultSortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                HStack {
                                    Image(systemName: option.icon)
                                    Text(option.displayName)
                                }
                                .tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                Section(header: Text("Scanning")) {
                    SimpleToggle(
                        isOn: $settings.enableNFC,
                        icon: "wave.3.right",
                        labelText: "Enable NFC"
                    )

                    SimpleToggle(
                        isOn: $settings.enableQR,
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
