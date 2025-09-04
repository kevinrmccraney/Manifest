//
//  QRCode.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//
import CoreImage.CIImage
import CoreImage.CIFilterBuiltins

func qrCode(inputMessage: String) -> CIImage {
    let qrCodeGenerator = CIFilter.qrCodeGenerator()
    qrCodeGenerator.message = inputMessage.data(using: .utf8)!
    qrCodeGenerator.correctionLevel = "H"
    return qrCodeGenerator.outputImage!
}
