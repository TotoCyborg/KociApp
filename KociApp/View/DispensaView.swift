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
                        DispensaCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.product?.brands ?? "Marca ignota")",
                            scadenza: "In Dispensa",
                            coloreBadge: verdeSalvia,
                            quantita: articolo.quantity, // Passiamo la quantità reale
                            aumentaQuantita: {
                                // Trova l'indice corretto, aumenta e salva
                                if let index = scannedItems.firstIndex(where: { $0.id == articolo.id }) {
                                    withAnimation { scannedItems[index].quantity += 1 }
                                    DataManager.saveItems(scannedItems)
                                }
                            },
                            diminuisciQuantita: {
                                // Trova l'indice, diminuisci (se > 1) e salva
                                if let index = scannedItems.firstIndex(where: { $0.id == articolo.id }) {
                                    if scannedItems[index].quantity > 1 {
                                        withAnimation { scannedItems[index].quantity -= 1 }
                                        DataManager.saveItems(scannedItems)
                                    }
                                }
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            scannedItems = DataManager.loadItems()
        }
        .sheet(isPresented: $isScannerShowing) {
            BarcodeScanner { code in
                addProduct(code: code)
            }
            .ignoresSafeArea()
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - MOTORE SCANNER E RETE
    // MARK: - MOTORE SCANNER E RETE
        func addProduct(code: String) {
            // 1. BLOCCO MULTI-SCAN: Se lo scanner si sta già chiudendo, ignora le altre letture
            guard isScannerShowing else { return }
            
            // 2. Chiudiamo logicamente lo scanner all'istante per bloccare i frame successivi
            isScannerShowing = false
            
            // Se esiste già, aumentiamo la quantità
            if let existingIndex = scannedItems.firstIndex(where: { $0.barcode == code }) {
                withAnimation { scannedItems[existingIndex].quantity += 1 }
                DataManager.saveItems(scannedItems)
                return
            }
            
            // Creiamo l'oggetto "in attesa"
            let newItem = ScannedItem(barcode: code, product: nil, isLoading: true)
            withAnimation { scannedItems.insert(newItem, at: 0) }
            DataManager.saveItems(scannedItems)
            
            // Lanciamo il task asincrono
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                do {
                    let foundProduct = try await FoodAPI.getProduct(barcode: code)
                    if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                        withAnimation {
                            scannedItems[index].product = foundProduct
                            scannedItems[index].isLoading = false
                        }
                        DataManager.saveItems(scannedItems)
                    }
                } catch {
                    if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                        withAnimation { scannedItems[index].isLoading = false }
                        DataManager.saveItems(scannedItems)
                    }
                }
            }
        }
    
    // MARK: - FUNZIONE ELIMINAZIONE
    func deleteItems(at offsets: IndexSet) {
        scannedItems.remove(atOffsets: offsets)
        DataManager.saveItems(scannedItems)
    }
}

// MARK: - CARD ALIMENTI CON STEPPER
struct DispensaCardView: View {
    var nome: String
    var dettaglio: String
    var scadenza: String
    var coloreBadge: Color
    
    // Nuove variabili per la gestione della quantità
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
                    .lineLimit(1) // Evita che nomi troppo lunghi sballino l'interfaccia
                
                Text(dettaglio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // VStack per allineare a destra Badge e Quantità
            VStack(alignment: .trailing, spacing: 12) {
                // badge scadenza
                Text(scadenza)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(coloreBadge)
                    .cornerRadius(12)
                
                // Stepper Quantità
                HStack(spacing: 8) {
                    Button(action: diminuisciQuantita) {
                        Image(systemName: "minus.square.fill")
                            .font(.title3)
                            .foregroundStyle(quantita > 1 ? verdeSalvia : .gray.opacity(0.3))
                    }
                    .buttonStyle(.borderless) // <-- Fondamentale dentro una List
                    
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
                    .buttonStyle(.borderless) // <-- Fondamentale dentro una List
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

#Preview {
    DispensaView()
}
