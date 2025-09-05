//
//  NFCWriterView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//


//
//  NFCWriterView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI
import CoreNFC

struct NFCWriterView: View {
    let itemID: UUID
    let itemName: String
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: WritingStep = .instruction
    @State private var isWriting = false
    @State private var writeComplete = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    private let nfcManager = NFCManager.shared
    
    enum WritingStep {
        case instruction
        case compatibility
        case writing
        case complete
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Circle()
                            .fill(stepColor(for: index))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top)
                
                Spacer()
                
                switch currentStep {
                case .instruction:
                    InstructionStepView(onContinue: {
                        withAnimation {
                            currentStep = .compatibility
                        }
                    })
                    
                case .compatibility:
                    CompatibilityStepView(onContinue: {
                        withAnimation {
                            currentStep = .writing
                        }
                    })
                    
                case .writing:
                    WritingStepView(
                        itemName: itemName,
                        isWriting: $isWriting,
                        onStartWriting: startWriting
                    )
                    
                case .complete:
                    CompleteStepView(onDone: {
                        dismiss()
                    })
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create NFC Tag")
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
    
    private func stepColor(for index: Int) -> Color {
        let currentIndex = currentStep.rawValue
        if index <= currentIndex {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private func setupNFCCallbacks() {
        nfcManager.onWriteComplete = {
            withAnimation {
                currentStep = .complete
                isWriting = false
            }
        }
        
        nfcManager.onError = { error in
            errorMessage = error
            showingError = true
            isWriting = false
        }
    }
    
    private func startWriting() {
        isWriting = true
        nfcManager.writeTag(with: itemID, itemName: itemName)
    }
}

extension NFCWriterView.WritingStep: RawRepresentable {
    var rawValue: Int {
        switch self {
        case .instruction: return 0
        case .compatibility: return 1
        case .writing: return 2
        case .complete: return 3
        }
    }
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .instruction
        case 1: self = .compatibility
        case 2: self = .writing
        case 3: self = .complete
        default: return nil
        }
    }
}

// MARK: - Step Views

struct InstructionStepView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wave.3.right.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                Text("Create NFC Tag")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("This will program an NFC tag to quickly open this item when scanned with any iPhone.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "1.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Get a blank NFC tag (NTAG213, NTAG215, or NTAG216)")
                }
                
                HStack {
                    Image(systemName: "2.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Follow the prompts to write your item data")
                }
                
                HStack {
                    Image(systemName: "3.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Attach the tag to your physical item")
                }
            }
            .font(.subheadline)
            
            Button("Continue") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct CompatibilityStepView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            
            VStack(spacing: 12) {
                Text("Compatibility Check")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Make sure you have:")
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("iPhone 7 or newer with iOS 13+")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("NFC enabled in Settings")
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Blank or rewritable NFC tag")
                }
                
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended tags:")
                        Text("NTAG213 (180 bytes) - Basic")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("NTAG215 (540 bytes) - Standard")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("NTAG216 (930 bytes) - Premium")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Button("Start Writing") {
                onContinue()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

struct WritingStepView: View {
    let itemName: String
    @Binding var isWriting: Bool
    let onStartWriting: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if isWriting {
                Image(systemName: "wave.3.right")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse)
            } else {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 12) {
                Text(isWriting ? "Writing to Tag..." : "Ready to Write")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if isWriting {
                    Text("Hold your iPhone steady near the NFC tag until writing is complete.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    ProgressView()
                        .scaleEffect(1.2)
                        .padding(.top, 8)
                } else {
                    Text("Tap the button below and then hold your iPhone near the NFC tag to write the data for \"\(itemName)\"")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }
            
            if !isWriting {
                Button("Write to Tag") {
                    onStartWriting()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
}

struct CompleteStepView: View {
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            
            VStack(spacing: 12) {
                Text("Tag Created!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your NFC tag has been successfully programmed. Anyone with an iPhone can now tap the tag to view this item in Manifest.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Next steps:")
                    .fontWeight(.medium)
                
                HStack {
                    Image(systemName: "1.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Attach the tag to your physical item")
                }
                
                HStack {
                    Image(systemName: "2.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Test the tag by scanning it with your iPhone")
                }
                
                HStack {
                    Image(systemName: "3.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Share the location with others who need access")
                }
            }
            .font(.subheadline)
            
            Button("Done") {
                onDone()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}