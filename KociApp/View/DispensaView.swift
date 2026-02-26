//
//  DispensaView.swift
//  KociApp_Grafica
//
//  Created by Toto La Piana on 25/02/26.
//

import SwiftUI

struct DispensaView: View {
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracottaBadge = Color(red: 0.72, green: 0.49, blue: 0.44)
    
    @State private var testoRicerca: String = ""
    @State private var scannedItems: [ScannedItem] = []
    @State private var isScannerShowing = false
    @State private var showDuplicateAlert = false
    
    @State private var isOCRScannerShowing = false
    @State private var ultimoCodiceScansionato: String = ""
    
    // Interruttore per cambiare la vista della data
    @State private var mostraContoAllaRovescia = false
    
    // 🚀 FILTRO E ORDINAMENTO (Chi scade prima va in alto!)
    var articoliFiltrati: [ScannedItem] {
        // 1. Prima applichiamo la ricerca testuale (se c'è)
        let filtrati = testoRicerca.isEmpty ? scannedItems : scannedItems.filter { item in
            let nome = item.product?.productName ?? "Sconosciuto"
            return nome.lowercased().contains(testoRicerca.lowercased())
        }
        
        // 2. Poi ordiniamo i risultati per data di scadenza
        return filtrati.sorted { (item1, item2) -> Bool in
            if let date1 = item1.expiryDate, let date2 = item2.expiryDate {
                return date1 < date2 // Se entrambi hanno la data, vince chi scade prima
            } else if item1.expiryDate != nil {
                return true  // Se solo item1 ha la data, va sopra
            } else if item2.expiryDate != nil {
                return false // Se solo item2 ha la data, va sopra lui
            }
            return false // Se nessuno dei due ha la data, restano dove sono
        }
    }
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // header
                VStack(spacing: 16) {
                    HStack {
                        Text("Pantry")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                            .padding(.top, 30)
                            .padding(.horizontal, 2)
                        
                        Spacer()
                        
                        // TASTO: Cambia visualizzazione Data / Giorni
                        Button(action: {
                            withAnimation {
                                mostraContoAllaRovescia.toggle()
                            }
                        }) {
                            Image(systemName: mostraContoAllaRovescia ? "timer" : "calendar")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(verdeSalvia)
                                .padding(.top, 30)
                                .padding(.horizontal, 8)
                        }
                        
                        // Tasto +
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
                        
                        // LOGICA MAGICA: Sceglie cosa scrivere nel badge
                        let testoScadenza: String = {
                            guard let dataTrovata = articolo.expiryDate else { return "Senza Data" }
                            
                            if mostraContoAllaRovescia {
                                // MODO CONTO ALLA ROVESCIA (Stile Dashboard)
                                let calendario = Calendar.current
                                let oggi = calendario.startOfDay(for: Date())
                                let giornoScadenza = calendario.startOfDay(for: dataTrovata)
                                let componenti = calendario.dateComponents([.day], from: oggi, to: giornoScadenza)
                                let giorniRimasti = componenti.day ?? 0
                                
                                if giorniRimasti < 0 { return "Expired" }
                                else if giorniRimasti == 0 { return "Today" }
                                else if giorniRimasti == 1 { return "Tomorrow" }
                                else { return "-\(giorniRimasti)" }
                                
                            } else {
                                // MODO CLASSICO (Data standard)
                                let f = DateFormatter()
                                f.dateStyle = .short
                                return f.string(from: dataTrovata)
                            }
                        }()
                        
                        let coloreScadenza: Color = {
                            guard let dataTrovata = articolo.expiryDate else { return verdeSalvia }
                            let calendario = Calendar.current
                            let oggi = calendario.startOfDay(for: Date())
                            let giornoScadenza = calendario.startOfDay(for: dataTrovata)
                            let componenti = calendario.dateComponents([.day], from: oggi, to: giornoScadenza)
                            let giorniRimasti = componenti.day ?? 0
                            return giorniRimasti <= 7 ? terracottaBadge : verdeSalvia
                        }()
                        
                        // COMPONENTE CONDIVISO (Con Tastini)
                        AlimentoCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                            scadenza: testoScadenza,
                            coloreBadge: coloreScadenza,
                            
                            mostraTastini: true,
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
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            scannedItems = DataManager.loadItems()
        }
        .sheet(isPresented: $isScannerShowing) {
            ZStack(alignment: .bottom) {
                BarcodeScanner(onScan: { code in
                    isScannerShowing = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        addProduct(code: code)
                    }
                })
                .ignoresSafeArea()
                
                Text("Inquadra il codice a barre")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 10)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isOCRScannerShowing) {
            ZStack(alignment: .bottom) {
                OCRScanner(onScan: { dataTrovata in
                    aggiungiDataAlProdotto(data: dataTrovata)
                })
                .ignoresSafeArea()
                
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
        ultimoCodiceScansionato = code
        if let existingIndex = scannedItems.firstIndex(where: { $0.barcode == code }) {
            withAnimation { scannedItems[existingIndex].quantity += 1 }
            DataManager.saveItems(scannedItems)
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
                    isOCRScannerShowing = true
                }
            } catch {
                await MainActor.run {
                    if let index = scannedItems.firstIndex(where: { $0.id == newItem.id }) {
                        scannedItems[index].isLoading = false
                        DataManager.saveItems(scannedItems)
                        isOCRScannerShowing = true
                    }
                }
            }
        }
    }
    
    // MARK: - MOTORE OCR (SALVA LA DATA)
    func aggiungiDataAlProdotto(data: Date) {
        if let index = scannedItems.firstIndex(where: { $0.barcode == ultimoCodiceScansionato }) {
            withAnimation {
                scannedItems[index].expiryDate = data
            }
            DataManager.saveItems(scannedItems)
            NotificationManager.shared.programmaNotifica(per: scannedItems[index])
        }
        isOCRScannerShowing = false
    }
    
    // MARK: - FUNZIONE ELIMINAZIONE
    func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { articoliFiltrati[$0].id }
        for id in idsToDelete {
            NotificationManager.shared.cancellaNotifica(id: id)
            scannedItems.removeAll(where: { item in
                idsToDelete.contains(item.id)
            })
            DataManager.saveItems(scannedItems)
        }
    }
}

#Preview {
    DispensaView()
}
