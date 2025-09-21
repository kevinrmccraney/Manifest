//
//  MultiFilePreviewView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-18.
//

import SwiftUI
import QuickLook
import UIKit

struct MultiFilePreviewView: UIViewControllerRepresentable {
    let attachments: [FileAttachment]
    let initialIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        previewController.delegate = context.coordinator
        previewController.currentPreviewItemIndex = initialIndex
        
        let navigationController = UINavigationController(rootViewController: previewController)
        
        previewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(context.coordinator.dismissPreview)
        )
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: MultiFilePreviewView
        private var tempURLs: [URL] = []
        
        init(_ parent: MultiFilePreviewView) {
            self.parent = parent
            super.init()
            createTempFiles()
        }
        
        deinit {
            cleanupTempFiles()
        }
        
        @objc func dismissPreview() {
            parent.dismiss()
        }
        
        private func createTempFiles() {
            let tempDir = FileManager.default.temporaryDirectory
            
            for attachment in parent.attachments {
                let tempFileURL = tempDir.appendingPathComponent(attachment.filename)
                
                do {
                    try attachment.fileData.write(to: tempFileURL)
                    tempURLs.append(tempFileURL)
                } catch {
                    print("Error creating temp file for \(attachment.filename): \(error)")
                }
            }
        }
        
        private func cleanupTempFiles() {
            for tempURL in tempURLs {
                try? FileManager.default.removeItem(at: tempURL)
            }
            tempURLs.removeAll()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return tempURLs.count
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return tempURLs[index] as QLPreviewItem
        }
        
        func previewControllerDidDismiss(_ controller: QLPreviewController) {
            parent.dismiss()
        }
        
        func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
            return .disabled
        }
        
        func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
            return true
        }
    }
}
