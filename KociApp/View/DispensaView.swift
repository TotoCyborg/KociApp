//
//  DispensaView.swift
//  KociApp_Grafica
//
//  Created by Toto La Piana on 25/02/26.
//

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
    
    // 🚀 Variabili per OCR
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
                    
                    // Titolo
                    HStack {
                        Text("Pantry")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                            .padding(.top, 30)
                            .padding(.horizontal, 2)
                        
                        Spacer()
                        
                        Button(action: {
                            isScannerShowing = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.top, 30)
                                .padding(.horizontal, 2)
                        }
                    }
                    
                    // Barra di ricerca
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
                
                // lista scroll
                List {
                    ForEach(articoliFiltrati) { articolo in
                        
                        // 🚀 Creiamo un formattatore date rapido per mostrare la data trovata
                        let dataFormat: String = {
                            if let dataTrovata = articolo.expiryDate {
                                let f = DateFormatter()
                                f.dateStyle = .short
                                return f.string(from: dataTrovata)
                            }
                            return "Senza Data"
                        }()
                        
                        // Passaggio dei dati
                        DispensaCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                            
                            // 🚀 Mostriamo la data vera!
                            scadenza: dataFormat,
                            coloreBadge: verdeSalvia,
                            quantita: articolo.quantity,
                            aumentaQuantita: {
                                if let index = scannedItems.firstIndex(where: { $0.id == articolo.id }) {
                                    withAnimation { scannedItems[index].quantity += 1 }
                                    DataManager.saveItems(scannedItems)
                                }
                            },
                            diminuisciQuantita: {
                                if let index = scannedItems.firstIndex(where: { $0.id == articolo.id }) {
                                    if scannedItems[index].quantity > 1 {
                                        withAnimation { scannedItems[index].quantity -= 1 }
                                        DataManager.saveItems(scannedItems)
                                    }
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems) // <-- RIAGGIUNTO LO SWIPE TO DELETE
                }
                .listStyle(.plain) // <-- CORRETTO: ORA È ATTACCATO ALLA LISTA
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
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
                    .padding(.bottom, 10)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        
        // --- 2° SCANNER: OCR ---
        .sheet(isPresented: $isOCRScannerShowing) {
            ZStack(alignment: .bottom) {
                
                // 1. Lo scanner dell'OCR
                OCRScanner(onScan: { dataTrovata in
                    aggiungiDataAlProdotto(data: dataTrovata)
                })
                .ignoresSafeArea()
                
                // 2. La scritta galleggiante per l'OCR
                Text("Inquadra la data di scadenza")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 10)
                
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - MOTORE SCANNER E RETE
    func addProduct(code: String) {
        
        // 🚀 Salviamo in memoria chi stiamo per aggiornare
        ultimoCodiceScansionato = code
        
        // Se esiste già, aumentiamo la quantità
        if let existingIndex = scannedItems.firstIndex(where: { $0.barcode == code }) {
            withAnimation { scannedItems[existingIndex].quantity += 1 }
            DataManager.saveItems(scannedItems)
            
            // Fa partire lo scanner della data
            isOCRScannerShowing = true
            return
        }
        
        let newItem = ScannedItem(barcode: code, product: nil, isLoading: true)
        withAnimation { scannedItems.insert(newItem, at: 0) }
        DataManager.saveItems(scannedItems)
        
        Task {
            do {
                let foundProduct = try await FoodAPI.getProduct(barcode: code)
                if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                    withAnimation {
                        scannedItems[index].product = foundProduct
                        scannedItems[index].isLoading = false
                    }
                    DataManager.saveItems(scannedItems)
                    
                    // Appena ha finito di scaricare, fa partire lo scanner della data!
                    isOCRScannerShowing = true
                }
            } catch {
                await MainActor.run {
                    if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                        scannedItems[index].isLoading = false
                        DataManager.saveItems(scannedItems)
                        
                        // Anche se non lo trova su internet, chiede la data
                        isOCRScannerShowing = true
                    }
                }
            }
        }
    }
    
    // MARK: - MOTORE OCR (SALVA LA DATA)
    func aggiungiDataAlProdotto(data: Date) {
        // Cerca l'ultimo prodotto scansionato e gli attribuisce la data
        if let index = scannedItems.firstIndex(where: { $0.barcode == ultimoCodiceScansionato }) {
            withAnimation {
                scannedItems[index].expiryDate = data
            }
            DataManager.saveItems(scannedItems)
            
            // 🚀 Programma la sveglia!
            NotificationManager.shared.programmaNotifica(per: scannedItems[index])
        }
        
        // Spegne lo scanner
        isOCRScannerShowing = false
    }
    
    // MARK: - FUNZIONE ELIMINAZIONE
    func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { articoliFiltrati[$0].id }
        
        // 🚀 Spegniamo la sveglia prima di buttare il cibo!
        for id in idsToDelete {
            NotificationManager.shared.cancellaNotifica(id: id)
            
            scannedItems.removeAll(where: { item in
                idsToDelete.contains(item.id)
            })
            DataManager.saveItems(scannedItems)
        }
    }
    
    // MARK: - CARD ALIMENTI CON STEPPER
    struct DispensaCardView: View {
        var nome: String
        var dettaglio: String
        var scadenza: String
        var coloreBadge: Color
        
        var quantita: Int
        var aumentaQuantita: () -> Void
        var diminuisciQuantita: () -> Void
        
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
                        .lineLimit(1)
                    
                    Text(dettaglio)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 12) {
                    Text(scadenza)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(coloreBadge)
                        .cornerRadius(12)
                    
                    HStack(spacing: 8) {
                        Button(action: diminuisciQuantita) {
                            Image(systemName: "minus.square.fill")
                                .font(.title3)
                                .foregroundStyle(quantita > 1 ? verdeSalvia : .gray.opacity(0.3))
                        }
                        .buttonStyle(.borderless)
                        
                        Text("\(quantita)")
                            .font(.headline)
                            .frame(width: 20)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(verdeSalvia)
                        
                        Button(action: aumentaQuantita) {
                            Image(systemName: "plus.square.fill")
                                .font(.title3)
                                .foregroundStyle(verdeSalvia)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .background(verdeSalvia.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}
    #Preview {
        DispensaView()
    }

