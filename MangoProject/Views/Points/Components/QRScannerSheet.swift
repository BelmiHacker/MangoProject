//
//  QRScannerSheet.swift
//  MangoProject
//

import SwiftUI
import VisionKit
internal import Vision

struct QRScannerSheet: View {
    var onCancel: () -> Void = {}
    var onScan: (String) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if DataScannerViewController.isSupported {
                QRDataScannerView(onScan: onScan)
                    .ignoresSafeArea()
            } else {
                unsupportedView
            }

            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black.opacity(0.45))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 56)
            .padding(.leading, 20)
        }
    }

    private var unsupportedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Camera not available")
                .font(.title3.bold())
            Text("QR scanning is not supported on this device.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Close", action: onCancel)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - UIViewControllerRepresentable

private struct QRDataScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .fast,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        private var hasScanned = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !hasScanned else { return }
            if case .barcode(let barcode) = addedItems.first,
               let payload = barcode.payloadStringValue {
                hasScanned = true
                onScan(payload)
            }
        }
    }
}
