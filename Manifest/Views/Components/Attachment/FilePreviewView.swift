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
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        previewController.delegate = context.coordinator
        
        // Create navigation controller to wrap the preview controller
        let navigationController = UINavigationController(rootViewController: previewController)
        
        // Set up the navigation bar
        previewController.navigationItem.title = fileAttachment.filename
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
        
        @objc func dismissPreview() {
            parent.dismiss()
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
        
        // Add support for sharing/saving files
        func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
            return .disabled
        }
        
        // Enable the action button (share/save)
        func previewController(_ controller: QLPreviewController, shouldOpen url: URL, for item: QLPreviewItem) -> Bool {
            return true
        }
        
        // Handle sharing actions
        func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
            return nil
        }
    }
}
