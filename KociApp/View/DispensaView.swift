//
//  DispensaView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//
/* view di elio*/

import SwiftUI

struct DispensaView: View {
    // colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracottaBadge = Color(red: 0.72, green: 0.49, blue: 0.44)
    let rossoOggi = Color(red: 0.71, green: 0.47, blue: 0.45)
    
    // variabile per ricerca
    @State private var testoRicerca: String = ""
    
    // kilo - Variabili di stato per i dati reali e scanner
    @State private var scannedItems: [ScannedItem] = []
    @State private var isScannerShowing = false
    @State private var showDuplicateAlert = false
    
    // 🚀 NOVITÀ: Variabili per la staffetta OCR
        @State private var isOCRScannerShowing = false
        @State private var ultimoCodiceScansionato: String = ""
    
    // match ricerca con dati reali
    var articoliFiltrati: [ScannedItem] {
        if testoRicerca.isEmpty {
            return scannedItems
        } else {
            return scannedItems.filter { item in
                let nome = item.product?.productName ?? "Sconosciuto"
                return nome.lowercased().contains(testoRicerca.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // header
                VStack(spacing: 16) {
                    
                    // Titolo tradotto: "Pantry"
                    HStack {
                        Text("Pantry")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                            .padding(.top, 30)
                            .padding(.horizontal, 2)
                        
                        Spacer()
                        
                        Button(action: {
                            // Azione che apre lo scanner
                            isScannerShowing = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.top, 30)
                                .padding(.horizontal, 2)
                        }
                    }
                    
                    // Barra di ricerca tradotta: "Search..."
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search...", text: $testoRicerca)
                            .foregroundColor(grigioScuroTesto)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // lista scroll (modificata in List per permettere lo swipe)
                List {
                    ForEach(articoliFiltrati) { articolo in
                        
                        // 🚀 NOVITÀ: Creiamo un formattatore date rapido per mostrare la data trovata
                                                let dataFormat: String = {
                                                    if let dataTrovata = articolo.expiryDate {
                                                        let f = DateFormatter()
                                                        f.dateStyle = .short
                                                        return f.string(from: dataTrovata)
                                                    }
                                                    return "Senza Data"
                                                }()
                        
                        // Passaggio dei dati veri alla tua grafica intatta
                        DispensaCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                            
                            // 🚀 NOVITÀ: Mostriamo la data vera invece di un testo fisso!
                                                        scadenza: dataFormat,
                                                        coloreBadge: verdeSalvia
                        )
                        // Questi modificatori nascondono lo stile di default della lista e tengono le tue spaziature
                        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems) // IL COMANDO MAGICO PER LO SWIPE
                }
                .listStyle(.plain) // Toglie lo stile di base
                .scrollContentBackground(.hidden) // Rende lo sfondo trasparente
                .padding(.bottom, 20)
            }
        }
        // Azioni che si attivano sulla schermata
        .onAppear {
            scannedItems = DataManager.loadItems()
        }
        
        // --- 1° SCANNER: CODICE A BARRE ---
                .sheet(isPresented: $isScannerShowing) {
                    ZStack(alignment: .bottom) {
                        // 1. Lo scanner del codice a barre
                        BarcodeScanner(onScan: { code in
                            isScannerShowing = false // Spegne il primo scanner...
                            
                            // Aspetta che si chiuda e lancia la staffetta
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                addProduct(code: code)
                            }
                        })
                        .ignoresSafeArea()
                        
                        // 2. La scritta galleggiante per il Barcode
                        Text("Inquadra il codice a barre")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                            .padding(.bottom, 10) // Distanza dal bordo inferiore
                    }
                    // Impostazioni della finestra (metà schermo + stanghetta)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
        
        // --- 2° SCANNER: OCR ---
           .sheet(isPresented: $isOCRScannerShowing) {
                ZStack(alignment: .bottom) {
                   
                     // 2. Lo scanner dell'OCR
                     OCRScanner(onScan: { dataTrovata in
                        aggiungiDataAlProdotto(data: dataTrovata)
                        })
                    .ignoresSafeArea()
                        
                // 2. La scritta galleggiante per l'OCR
                Text("Inquadra la data di scadenza")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2) // Ombra per leggerla anche su sfondi chiari
                .padding(.bottom, 10) // La tiene un po' sollevata dal bordo inferiore
            
             }
            // Impostazioni della finestra (metà schermo + stanghetta)
           .presentationDetents([.medium, .large])
           .presentationDragIndicator(.visible)
            
                }
            }
    
    // MARK: - MOTORE SCANNER E RETE
    func addProduct(code: String) {
        
        // 🚀 NOVITÀ: Salviamo in memoria chi stiamo per aggiornare
                ultimoCodiceScansionato = code
        
        // Se esiste già, aumentiamo la quantità
        if let existingIndex = scannedItems.firstIndex(where: { $0.barcode == code }) {
            scannedItems[existingIndex].quantity += 1
            DataManager.saveItems(scannedItems)
            
            // 🚀 Fa partire lo scanner della data
                        isOCRScannerShowing = true
                        return
            
        }
        
        // Creiamo l'oggetto "in attesa"
        let newItem = ScannedItem(barcode: code, product: nil, isLoading: true)
        scannedItems.insert(newItem, at: 0)
        DataManager.saveItems(scannedItems)
        isScannerShowing = false
        
        // Lanciamo il task asincrono
        Task {
            
            do {
                let foundProduct = try await FoodAPI.getProduct(barcode: code)
                if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                    scannedItems[index].product = foundProduct
                    scannedItems[index].isLoading = false
                    DataManager.saveItems(scannedItems)
                    
                    // 🚀 Appena ha finito di scaricare, fa partire lo scanner della data!
                    isOCRScannerShowing = true

                }
            } catch {
                await MainActor.run {
                    if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                        scannedItems[index].isLoading = false
                        DataManager.saveItems(scannedItems)
                        
                        // 🚀 Anche se non lo trova su internet, chiede la data
                        isOCRScannerShowing = true
                    }
                }
            }
        }
    }
    // MARK: - MOTORE OCR (SALVA LA DATA)
        func aggiungiDataAlProdotto(data: Date) {
                // Cerca l'ultimo prodotto scansionato e gli inietta la data
                if let index = scannedItems.firstIndex(where: { $0.barcode == ultimoCodiceScansionato }) {
                    scannedItems[index].expiryDate = data
                    DataManager.saveItems(scannedItems)
                }
                
                // Spegne lo scanner
                isOCRScannerShowing = false
            }
        
    // MARK: - FUNZIONE ELIMINAZIONE
    func deleteItems(at offsets: IndexSet) {
        scannedItems.remove(atOffsets: offsets)
        DataManager.saveItems(scannedItems)
    }
}

// MARK: - CARD ALIMENTI (INTATTA)
struct DispensaCardView: View {
    var nome: String
    var dettaglio: String
    var scadenza: String
    var coloreBadge: Color
    
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    var body: some View {
        HStack(spacing: 16) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(verdeSalvia.opacity(0.15))
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(verdeSalvia)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nome)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(grigioScuroTesto)
                
                Text(dettaglio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // badge scadenza
            Text(scadenza)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(coloreBadge)
                .cornerRadius(12)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DispensaView()
}
