//
//  NFCManager.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//


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
    
    // MARK: - NFC Reading
    func startReading() {
        guard NFCNDEFReaderSession.readingAvailable else {
            onError?("NFC is not available on this device")
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to scan it"
        nfcSession?.begin()
    }
    
    // MARK: - NFC Writing
    func writeTag(with itemID: UUID, itemName: String) {
        guard NFCNDEFReaderSession.readingAvailable else {
            onError?("NFC is not available on this device")
            return
        }
        
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
        // Handle session invalidation
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                // User canceled - don't show error
                break
            case .readerSessionInvalidationErrorSessionTimeout:
                DispatchQueue.main.async {
                    self.onError?("Session timed out. Please try again.")
                }
            default:
                DispatchQueue.main.async {
                    self.onError?("NFC session error: \(nfcError.localizedDescription)")
                }
            }
        }
        
        // Clean up sessions
        nfcSession = nil
        nfcWriteSession = nil
        pendingWriteData = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Handle reading tags
        for message in messages {
            for record in message.records {
                if let url = record.wellKnownTypeURIPayload() {
                    // Handle URL payload
                    if let itemID = extractItemID(from: url) {
                        DispatchQueue.main.async {
                            self.onTagRead?(itemID)
                        }
                        return
                    }
                } else if record.typeNameFormat == .nfcWellKnown && record.type == Data([0x54]) {
                    // Handle text payload (fallback)
                    if let string = String(data: record.payload.dropFirst(3), encoding: .utf8),
                       let itemID = UUID(uuidString: string) {
                        DispatchQueue.main.async {
                            self.onTagRead?(itemID)
                        }
                        return
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.onError?("Could not read item data from this tag")
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // Handle writing to tags
        guard let pendingData = pendingWriteData else { return }
        
        if tags.count > 1 {
            session.alertMessage = "More than 1 tag found. Please present a single tag."
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if let error = error {
                session.alertMessage = "Connection failed: \(error.localizedDescription)"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.alertMessage = "Query failed: \(error.localizedDescription)"
                    session.invalidate()
                    return
                }
                
                switch status {
                case .notSupported:
                    session.alertMessage = "This tag doesn't support NDEF"
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "This tag is read-only"
                    session.invalidate()
                case .readWrite:
                    let message = self.createNDEFMessage(for: pendingData.itemID, itemName: pendingData.itemName)
                    
                    tag.writeNDEF(message) { error in
                        if let error = error {
                            session.alertMessage = "Write failed: \(error.localizedDescription)"
                        } else {
                            session.alertMessage = "Successfully wrote item to NFC tag!"
                            DispatchQueue.main.async {
                                self.onWriteComplete?()
                            }
                        }
                        session.invalidate()
                    }
                @unknown default:
                    session.alertMessage = "Unknown tag status"
                    session.invalidate()
                }
            }
        }
    }
    
    private func extractItemID(from url: URL) -> UUID? {
        // Extract UUID from manifest://item/{uuid} URL
        if url.scheme == "manifest" && url.host == "item" {
            let pathComponents = url.pathComponents
            if pathComponents.count >= 2 {
                let uuidString = pathComponents[1]
                return UUID(uuidString: uuidString)
            }
        }
        return nil
    }
}