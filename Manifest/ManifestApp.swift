//
//  ManifestApp.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import SwiftData

@main
struct ManifestApp: App {
    @StateObject private var iCloudSettings = ICloudSettings()
    
    var sharedModelContainer: ModelContainer {
        let schema = Schema([
            Item.self,
            FileAttachment.self,
        ])
        
        // Create configuration based on iCloud setting
        let modelConfiguration: ModelConfiguration
        if iCloudSettings.isEnabled && iCloudSettings.isAvailable {
            // iCloud-enabled configuration
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
        } else {
            // Local-only configuration
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(AppTheme.secondaryBackground.ignoresSafeArea())
                .environmentObject(iCloudSettings)
        }
        .modelContainer(sharedModelContainer)
        .handlesExternalEvents(matching: ["manifest"])
    }
}

// MARK: - iCloud Settings Manager

class ICloudSettings: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "iCloudSyncEnabled")
        }
    }
    
    @Published var isAvailable: Bool = false
    
    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        checkiCloudAvailability()
        
        // Listen for iCloud account changes
        NotificationCenter.default.addObserver(
            forName: .NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.checkiCloudAvailability()
        }
    }
    
    func checkiCloudAvailability() {
        let token = FileManager.default.ubiquityIdentityToken
        print("iCloud Debug: ubiquityIdentityToken = \(token?.description ?? "nil")")
        
        // Check if user is signed into iCloud AND has iCloud Drive enabled
        if token != nil {
            // Additional check for iCloud Drive availability
            if let ubiquityURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                print("iCloud Debug: iCloud Drive available at \(ubiquityURL)")
                isAvailable = true
            } else {
                print("iCloud Debug: iCloud Drive not available")
                isAvailable = false
                isEnabled = false
                
                func openSystemSettings() {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
        }
    }
}
