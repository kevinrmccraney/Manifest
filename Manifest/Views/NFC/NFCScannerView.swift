//
//  NFCScannerView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI
import CoreNFC

struct NFCScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isScanning = false
    @State private var scannedItemID: UUID?
    @State private var errorMessage: String?
    @State private var showingError = false
    
    let onItemFound: (UUID) -> Void
    
    private let nfcManager = NFCManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 24) {
                    // NFC Icon with animation
                    if isScanning {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                            .symbolEffect(.pulse)
                    } else {
                        Image(systemName: "wave.3.right.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(spacing: 12) {
                        Text(isScanning ? "Scanning..." : "Scan NFC Tag")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(isScanning ? "Hold your iPhone near the NFC tag" : "Tap the button below and hold your iPhone near an NFC tag created with Manifest")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                    if isScanning {
                        Button("Cancel Scanning") {
                            // NFC session will be invalidated automatically
                            isScanning = false
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Start Scanning") {
                            startScanning()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                
                Spacer()
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tips for scanning:")
                        .font(.headline)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "1.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Position the top of your iPhone near the NFC tag")
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "2.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Hold steady for a few seconds")
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "3.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Make sure the tag was created with Manifest")
                    }
                }
                .font(.subheadline)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Scan NFC Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                setupNFCCallbacks()
            }
        }
    }
    
    private func setupNFCCallbacks() {
        nfcManager.onTagRead = { itemID in
            scannedItemID = itemID
            onItemFound(itemID)
            dismiss()
        }
        
        nfcManager.onError = { error in
            errorMessage = error
            showingError = true
            isScanning = false
        }
    }
    
    private func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            errorMessage = "NFC is not available on this device"
            showingError = true
            return
        }
        
        isScanning = true
        nfcManager.startReading()
    }
}
