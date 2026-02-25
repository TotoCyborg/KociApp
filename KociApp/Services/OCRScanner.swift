//
//  File.swift
//  KociApp
//
//  Created by GIORGIO GALIOTO on 25/02/26.
//

import Foundation
import SwiftUI
import VisionKit

struct OCRScanner: UIViewControllerRepresentable {
    // Quando trova una data vera, la restituisce all'app
    var onScan: (Date) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Configuriamo lo scanner per leggere il TESTO (non i codici a barre)
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate, // Massima precisione
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        
        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
            DispatchQueue.main.async {
                do {
                    try scanner.startScanning()
                } catch {
                    print("Errore critico avvio OCR: \(error.localizedDescription)")
                }
            }
        }
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Coordinator (Il Cervello)
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: OCRScanner
        
        init(parent: OCRScanner) {
            self.parent = parent
        }
        
        // Questa funzione scatta quando la fotocamera vede del testo
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = addedItems.first else { return }
            
            switch item {
            case .text(let textItem):
                let testoEstratto = textItem.transcript
                analizzaTesto(testoEstratto)
            default:
                break
            }
        }
        
        // IL NOSTRO SUPER-BUTTAFUORI (Filtra date false e numeri)
        private func analizzaTesto(_ testo: String) {
            var testoDaAnalizzare = testo
            
            // 1. ELIMINA GLI ORARI (Es. "14:30")
            let orarioPattern = "\\b\\d{1,2}:\\d{2}(:\\d{2})?\\b"
            if let orarioRegex = try? NSRegularExpression(pattern: orarioPattern) {
                let range = NSRange(location: 0, length: testoDaAnalizzare.utf16.count)
                testoDaAnalizzare = orarioRegex.stringByReplacingMatches(in: testoDaAnalizzare, options: [], range: range, withTemplate: "")
            }

            // 2. SISTEMA LE DATE INDUSTRIALI (Es. "12 02 27" -> "12/02/27")
            let dataPattern = "\\b(\\d{2})[\\s\\.-](\\d{2})[\\s\\.-](\\d{2,4})\\b"
            if let dataRegex = try? NSRegularExpression(pattern: dataPattern) {
                let range = NSRange(location: 0, length: testoDaAnalizzare.utf16.count)
                testoDaAnalizzare = dataRegex.stringByReplacingMatches(in: testoDaAnalizzare, options: [], range: range, withTemplate: "$1/$2/$3")
            }
            
            // 3. RICERCA LA DATA
            do {
                let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
                let matches = detector.matches(in: testoDaAnalizzare, options: [], range: NSRange(location: 0, length: testoDaAnalizzare.utf16.count))
                
                for match in matches {
                    if let date = match.date {
                        if let range = Range(match.range, in: testoDaAnalizzare) {
                            let parolaTrovata = String(testoDaAnalizzare[range]).lowercased()
                            
                            // Blacklist
                            if parolaTrovata.contains("oggi") || parolaTrovata.contains("domani") || parolaTrovata.contains("ieri") {
                                continue
                            }
                            
                            // Conteggio numeri (max 8)
                            let quantiNumeri = parolaTrovata.filter { $0.isNumber }.count
                            if quantiNumeri >= 2 && quantiNumeri <= 8 {
                                
                                // Vibrazione quando trova la data
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                
                                // Restituisce la data all'app!
                                DispatchQueue.main.async {
                                    self.parent.onScan(date)
                                }
                                return
                            }
                        }
                    }
                }
            } catch {
                print("Errore detector: \(error)")
            }
        }
    }
}
