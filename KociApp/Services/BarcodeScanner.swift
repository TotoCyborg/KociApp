import SwiftUI
import VisionKit
import AVFoundation

struct BarcodeScanner: UIViewControllerRepresentable {
    
    // La closure che viene chiamata quando troviamo un codice
    var onScan: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        
        // Scanner configuration:
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false, // Only 1 x time
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        
        // Version Control
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            
            // Async start
            DispatchQueue.main.async {//aspetta la UI
                do {//Explain error in cacth part
                    try scanner.startScanning()
                } catch {
                    print("Errore critico avvio scanner: \(error.localizedDescription)")
                    // Implement ipotetic messagge error for user
                }
            }
        } else {
            print("Dispositivo non supportato o fotocamera non disponibile")
        }
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // No code for simple scanner
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        var parent: BarcodeScanner
        
        init(parent: BarcodeScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            
            guard let item = addedItems.first else { return }
            
            switch item {
            case .barcode(let code):
                guard let payload = code.payloadStringValue else { return }
                
                // vibrazione
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                // Thread Safety
                DispatchQueue.main.async {// Update UI from main thread
                    self.parent.onScan(payload)
                }
                
            default:
                break
            }
        }
    }
}
