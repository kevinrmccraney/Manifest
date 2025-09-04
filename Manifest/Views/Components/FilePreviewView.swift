//
//  FilePreviewView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI
import QuickLook
import UIKit

struct FilePreviewView: UIViewControllerRepresentable {
    let fileAttachment: FileAttachment
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: FilePreviewView
        private var tempURL: URL?
        
        init(_ parent: FilePreviewView) {
            self.parent = parent
            super.init()
            createTempFile()
        }
        
        deinit {
            cleanupTempFile()
        }
        
        private func createTempFile() {
            let tempDir = FileManager.default.temporaryDirectory
            let tempFileURL = tempDir.appendingPathComponent(parent.fileAttachment.filename)
            
            do {
                try parent.fileAttachment.fileData.write(to: tempFileURL)
                tempURL = tempFileURL
            } catch {
                print("Error creating temp file: \(error)")
            }
        }
        
        private func cleanupTempFile() {
            guard let tempURL = tempURL else { return }
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return tempURL != nil ? 1 : 0
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return tempURL! as QLPreviewItem
        }
        
        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            parent.dismiss()
        }
    }
}
