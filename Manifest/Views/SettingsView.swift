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
                    
                    // Show Attachment Icons Setting
                    SimpleToggle(
                        isOn: $settings.showAttachmentIcons,
                        icon: "paperclip",
                        labelText: "Show Attachment Icons"
                    )
                    
                }
                
                Section(header: Text("Scanning")) {

                    
                    // Show NFC Toggle
                    SimpleToggle(
                        isOn: $settings.enableNFC,
                        icon: "wave.3.right",
                        labelText: "Enable NFC"
                    )
                    
                    // Show QR Toggle
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
