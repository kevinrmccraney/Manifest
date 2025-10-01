//
//  SettingsView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var settings = AppSettings.shared
    @State private var localGlobalSearch: Bool = AppSettings.shared.globalSearch
    @State private var onboardingManager = OnboardingManager.shared
    @EnvironmentObject var iCloudSettings: ICloudSettings

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
                    
                    SimpleToggle(
                        isOn: $settings.showItemDescriptions,
                        icon: "text.alignleft",
                        labelText: "Show Item Descriptions"
                    )
                    SimpleToggle(
                        isOn: $settings.showSortPicker,
                        icon: "arrow.up.arrow.down",
                        labelText: "Show Sorting Options"
                    )
                }
                
                // Search Settings Section
                Section(header: Text("Search")) {
                    SimpleToggle(
                        isOn: $localGlobalSearch,
                        icon: "magnifyingglass.circle",
                        labelText: "Global Search"
                    )
                    .onChange(of: localGlobalSearch) { _, newValue in
                        settings.globalSearch = newValue
                    }
                    
                    if !localGlobalSearch {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.blue)
                                .frame(width: 24, height: 24)
                            Text("Search will only include items from the current view (active or archived)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                }
                Section(header: Text("Sorting")) {
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

                Section(header: Text("Data Sync")) {
                    if iCloudSettings.isAvailable {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "icloud")
                                    .foregroundStyle(.blue)
                                    .frame(width: 24, height: 24)
                                
                                Text("iCloud Sync")
                                
                                Spacer()
                                
                                Toggle("", isOn: $iCloudSettings.isEnabled)
                                    .labelsHidden()
                            }
                            
                            ConditionalTextComponent(
                                icon: "info.circle",
                                primaryLabelText: "Your items will sync across all your devices signed into the same iCloud account. Restart the app to apply changes.",
                                secondaryLabelText: "Items are stored locally on this device only. Restart the app to apply changes.",
                                conditional: iCloudSettings.isEnabled
                            )
                        }
                    } else {
                        HStack {
                            Image(systemName: "icloud.slash")
                                .foregroundStyle(.gray)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("iCloud Not Available")
                                Text("Sign into iCloud in Settings to enable sync")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                    if settings.debugMode {
                        Button("Refresh iCloud Status") {
                            iCloudSettings.checkiCloudAvailability()
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                }
                
                if settings.debugMode {
                    Section(header: Text("Debug")) {
                        HStack {
                            Text("Onboarding Status:")
                            Spacer()
                            Text(onboardingManager.hasCompletedOnboarding ? "Completed" : "Not Completed")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Reset Onboarding") {
                            onboardingManager.resetOnboarding()
                        }
                        .foregroundStyle(.orange)
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

