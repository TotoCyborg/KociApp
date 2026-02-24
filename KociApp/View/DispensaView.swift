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
                        // Passaggio dei dati veri alla tua grafica intatta
                        DispensaCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                            scadenza: "In Dispensa", // Mettiamo un testo fisso per non rompere il tuo badge
                            coloreBadge: verdeSalvia // Mettiamo un colore fisso per non rompere il tuo badge
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
        .sheet(isPresented: $isScannerShowing) {
            BarcodeScanner { code in
                addProduct(code: code)
            }
            .ignoresSafeArea()
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - MOTORE SCANNER E RETE
    func addProduct(code: String) {
        // Se esiste già, aumentiamo la quantità
        if let existingIndex = scannedItems.firstIndex(where: { $0.barcode == code }) {
            scannedItems[existingIndex].quantity += 1
            DataManager.saveItems(scannedItems)
            isScannerShowing = false
            return
        }
        
        // Creiamo l'oggetto "in attesa"
        let newItem = ScannedItem(barcode: code, product: nil, isLoading: true)
        scannedItems.insert(newItem, at: 0)
        DataManager.saveItems(scannedItems)
        isScannerShowing = false
        
        // Lanciamo il task asincrono
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            do {
                let foundProduct = try await FoodAPI.getProduct(barcode: code)
                if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                    scannedItems[index].product = foundProduct
                    scannedItems[index].isLoading = false
                    DataManager.saveItems(scannedItems)
                }
            } catch {
                if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                    scannedItems[index].isLoading = false
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
