//
//  QRScannerView.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-04.
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    let onCodeScanned: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingItemNotFound = false
    @State private var showingCameraPermissionAlert = false
    @State private var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    
    var body: some View {
        NavigationView {
            Group {
                #if targetEnvironment(simulator)
                // Simulator fallback
                MockQRScannerView(onCodeScanned: onCodeScanned)
                #else
                // Real device implementation
                if cameraPermissionStatus == .authorized {
                    ZStack {
                        QRCodeScannerViewController { result in
                            switch result {
                            case .success(let code):
                                handleScannedCode(code)
                            case .failure:
                                showingItemNotFound = true
                            }
                        }
                        .ignoresSafeArea()
                        
                        // Overlay with scanning frame
                        VStack {
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 250, height: 250)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                )
                            
                            Spacer()
                            
                            Text("Hold your camera over a QR code")
                                .foregroundStyle(.white)
                                .font(.headline)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .cornerRadius(10)
                                .padding(.bottom, 50)
                        }
                    }
                } else {
                    // Camera permission not granted
                    VStack(spacing: 24) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("To scan QR codes, please allow camera access in Settings.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        if cameraPermissionStatus == .denied {
                            Button("Open Settings") {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Request Camera Access") {
                                requestCameraPermission()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
                #endif
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .alert("Item Not Found", isPresented: $showingItemNotFound) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("The scanned QR code contains an item ID that doesn't exist in your Manifest. The item may have been deleted or belongs to a different user.")
            }
            .onAppear {
                checkCameraPermission()
            }
        }
    }
    
    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        if cameraPermissionStatus == .notDetermined {
            requestCameraPermission()
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        // Try to parse as URL first (for manifest:// URLs)
        if let url = URL(string: code), url.scheme == "manifest", url.host == "item" {
            let pathComponents = url.pathComponents
            if pathComponents.count >= 2 {
                let uuidString = pathComponents[1]
                if let itemID = UUID(uuidString: uuidString) {
                    onCodeScanned(itemID)
                    dismiss()
                    return
                }
            }
        }
        
        // Try to parse as plain UUID string (fallback)
        if let itemID = UUID(uuidString: code) {
            onCodeScanned(itemID)
            dismiss()
            return
        }
        
        // If we get here, it's not a valid code
        showingItemNotFound = true
    }
}

struct QRCodeScannerViewController: UIViewControllerRepresentable {
    let onCodeScanned: (Result<String, ScanError>) -> Void
    
    enum ScanError: Error {
        case invalidCode
        case cameraPermissionDenied
        case cameraNotAvailable
    }
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRCodeScannerViewController
        
        init(_ parent: QRCodeScannerViewController) {
            self.parent = parent
        }
        
        func qrScannerDidScan(_ code: String) {
            parent.onCodeScanned(.success(code))
        }
        
        func qrScannerDidFail() {
            parent.onCodeScanned(.failure(.invalidCode))
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerDidScan(_ code: String)
    func qrScannerDidFail()
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var hasScanned = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        // Check camera permission first
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        guard authStatus == .authorized else {
            print("Camera permission not granted: \(authStatus)")
            delegate?.qrScannerDidFail()
            return
        }
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video capture device available")
            delegate?.qrScannerDidFail()
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error creating video input: \(error)")
            delegate?.qrScannerDidFail()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Cannot add video input to capture session")
            delegate?.qrScannerDidFail()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Cannot add metadata output to capture session")
            delegate?.qrScannerDidFail()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func startScanning() {
        if captureSession != nil && !captureSession.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func stopScanning() {
        if captureSession != nil && captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        guard !hasScanned else { return }
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            hasScanned = true
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            delegate?.qrScannerDidScan(stringValue)
        }
    }
}

// Simulator fallback
#if targetEnvironment(simulator)
struct MockQRScannerView: View {
    let onCodeScanned: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var mockUUID = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Text("QR Scanner")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Simulator Mode - Enter UUID manually")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("Enter Item UUID", text: $mockUUID)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("Simulate Scan") {
                if let uuid = UUID(uuidString: mockUUID) {
                    onCodeScanned(uuid)
                    dismiss()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(mockUUID.isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationTitle("QR Scanner (Mock)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}
#endif
