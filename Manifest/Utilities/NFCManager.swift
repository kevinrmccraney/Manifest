//
//  NFCManager.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import Foundation
import CoreNFC
import SwiftUI

@Observable
class NFCManager: NSObject, ObservableObject {
    static let shared = NFCManager()
    
    private var nfcSession: NFCNDEFReaderSession?
    private var nfcWriteSession: NFCNDEFReaderSession?
    
    // Callbacks for handling results
    var onTagRead: ((UUID) -> Void)?
    var onWriteComplete: (() -> Void)?
    var onError: ((String) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // Check if NFC is available on this device
    var isNFCAvailable: Bool {
        return NFCNDEFReaderSession.readingAvailable
    }
    
    // MARK: - NFC Reading
    func startReading() {
        print("Checking NFC availability...")
        
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC reading not available - readingAvailable returned false")
            
            // More specific error messages
            #if targetEnvironment(simulator)
            onError?("NFC is not supported in the iOS Simulator. Please test on a physical device.")
            #else
            onError?("NFC is not available on this device. Make sure you have an iPhone 7 or newer with iOS 11+ and NFC is enabled in Settings.")
            #endif
            return
        }
        
        print("NFC is available, starting session...")
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to scan it"
        nfcSession?.begin()
    }
    
    // MARK: - NFC Writing
    func writeTag(with itemID: UUID, itemName: String) {
        print("Starting NFC write for item: \(itemName)")
        
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC writing not available - readingAvailable returned false")
            
            #if targetEnvironment(simulator)
            onError?("NFC is not supported in the iOS Simulator. Please test on a physical device.")
            #else
            onError?("NFC is not available on this device. Make sure you have an iPhone 7 or newer with iOS 11+ and NFC is enabled in Settings.")
            #endif
            return
        }
        
        print("NFC is available for writing, starting session...")
        
        nfcWriteSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcWriteSession?.alertMessage = "Hold your iPhone near an NFC tag to write the item data"
        nfcWriteSession?.begin()
        
        // Store the data we want to write
        pendingWriteData = (itemID: itemID, itemName: itemName)
    }
    
    private var pendingWriteData: (itemID: UUID, itemName: String)?
    
    private func createNDEFMessage(for itemID: UUID, itemName: String) -> NFCNDEFMessage {
        // Create a URL record that will deep link to our app
        let urlString = "manifest://item/\(itemID.uuidString)"
        
        guard let url = URL(string: urlString),
              let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(url: url) else {
            // Fallback to text payload if URL creation fails
            let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(string: itemID.uuidString, locale: Locale(identifier: "en"))!
            return NFCNDEFMessage(records: [textPayload])
        }
        
        // Also add a text record with the item name for human readability
        let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(string: itemName, locale: Locale(identifier: "en"))!
        
        return NFCNDEFMessage(records: [urlPayload, textPayload])
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC session invalidated with error: \(error)")
        
        // Handle session invalidation
        if let nfcError = error as? NFCReaderError {
            print("NFC error code: \(nfcError.code.rawValue)")
            print("NFC error description: \(nfcError.localizedDescription)")
            
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                print("User canceled NFC session")
                // User canceled - don't show error
                break
            case .readerSessionInvalidationErrorSessionTimeout:
                print("NFC session timed out")
                DispatchQueue.main.async {
                    self.onError?("Session timed out. Please try again.")
                }
            case .readerSessionInvalidationErrorSystemIsBusy:
                print("NFC system is busy")
                DispatchQueue.main.async {
                    self.onError?("NFC is busy. Please wait a moment and try again.")
                }
            case .readerSessionInvalidationErrorFirstNDEFTagRead:
                print("First NDEF tag read")
                // This is actually success for read operations
                break
            default:
                print("Other NFC error: \(nfcError.localizedDescription)")
                DispatchQueue.main.async {
                    self.onError?("NFC error: \(nfcError.localizedDescription)")
                }
            }
        } else {
            print("Non-NFC error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.onError?("Unexpected error: \(error.localizedDescription)")
            }
        }
        
        // Clean up sessions
        nfcSession = nil
        nfcWriteSession = nil
        pendingWriteData = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NFC detected \(messages.count) NDEF messages")
        
        // Handle reading tags
        for message in messages {
            print("Processing message with \(message.records.count) records")
            
            for record in message.records {
                print("Processing record of type: \(record.typeNameFormat)")
                
                if let url = record.wellKnownTypeURIPayload() {
                    print("Found URL: \(url)")
                    // Handle URL payload
                    if let itemID = extractItemID(from: url) {
                        print("Extracted item ID: \(itemID)")
                        DispatchQueue.main.async {
                            self.onTagRead?(itemID)
                        }
                        return
                    }
                } else if record.typeNameFormat == .nfcWellKnown && record.type == Data([0x54]) {
                    print("Found text record")
                    // Handle text payload (fallback)
                    if let string = String(data: record.payload.dropFirst(3), encoding: .utf8) {
                        print("Text content: \(string)")
                        if let itemID = UUID(uuidString: string) {
                            print("Extracted UUID from text: \(itemID)")
                            DispatchQueue.main.async {
                                self.onTagRead?(itemID)
                            }
                            return
                        }
                    }
                }
            }
        }
        
        print("Could not extract valid item ID from any record")
        DispatchQueue.main.async {
            self.onError?("Could not read item data from this tag")
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("NFC detected \(tags.count) tags for writing")
        
        // Handle writing to tags
        guard let pendingData = pendingWriteData else {
            print("No pending write data")
            return
        }
        
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag found. Please present a single tag."
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if let error = error {
                print("Failed to connect to tag: \(error)")
                session.alertMessage = "Connection failed: \(error.localizedDescription)"
                session.invalidate()
                return
            }
            
            print("Successfully connected to tag")
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    print("Failed to query NDEF status: \(error)")
                    session.alertMessage = "Query failed: \(error.localizedDescription)"
                    session.invalidate()
                    return
                }
                
                print("Tag status: \(status), capacity: \(capacity)")
                
                switch status {
                case .notSupported:
                    print("Tag doesn't support NDEF")
                    session.alertMessage = "This tag doesn't support NDEF"
                    session.invalidate()
                case .readOnly:
                    print("Tag is read-only")
                    session.alertMessage = "This tag is read-only"
                    session.invalidate()
                case .readWrite:
                    print("Tag is writable, creating message...")
                    let message = self.createNDEFMessage(for: pendingData.itemID, itemName: pendingData.itemName)
                    
                    tag.writeNDEF(message) { error in
                        if let error = error {
                            print("Failed to write NDEF: \(error)")
                            session.alertMessage = "Write failed: \(error.localizedDescription)"
                        } else {
                            print("Successfully wrote NDEF message")
                            session.alertMessage = "Successfully wrote item to NFC tag!"
                            DispatchQueue.main.async {
                                self.onWriteComplete?()
                            }
                        }
                        session.invalidate()
                    }
                @unknown default:
                    print("Unknown tag status")
                    session.alertMessage = "Unknown tag status"
                    session.invalidate()
                }
            }
        }
    }
    
    private func extractItemID(from url: URL) -> UUID? {
        print("Extracting item ID from URL: \(url)")
        
        // Extract UUID from manifest://item/{uuid} URL
        if url.scheme == "manifest" && url.host == "item" {
            let pathComponents = url.pathComponents
            print("URL path components: \(pathComponents)")
            
            if pathComponents.count >= 2 {
                let uuidString = pathComponents[1]
                print("Attempting to parse UUID: \(uuidString)")
                return UUID(uuidString: uuidString)
            }
        }
        
        print("Could not extract item ID from URL")
        return nil
    }
}
