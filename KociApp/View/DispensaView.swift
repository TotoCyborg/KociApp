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
    @State private var idUltimoScansionato: ScannedItem.ID? = nil
    
    @State private var mostraContoAllaRovescia = false
    
    // 🚀 ASCOLTIAMO L'APP PER PULIRE I VECCHI SCADUTI QUANDO SI RIAPRE
    @Environment(\.scenePhase) var scenePhase
    
    var articoliFiltrati: [ScannedItem] {
        let filtrati = testoRicerca.isEmpty ? scannedItems : scannedItems.filter { item in
            let nome = item.product?.productName ?? "Sconosciuto"
            return nome.lowercased().contains(testoRicerca.lowercased())
        }
        
        return filtrati.sorted { (item1, item2) -> Bool in
            if let date1 = item1.expiryDate, let date2 = item2.expiryDate {
                return date1 < date2
            } else if item1.expiryDate != nil {
                return true
            } else if item2.expiryDate != nil {
                return false
            }
            return false
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
                        
                        let calendario = Calendar.current
                        let oggi = calendario.startOfDay(for: Date())
                        let giorniRimasti: Int? = {
                            guard let data = articolo.expiryDate else { return nil }
                            return calendario.dateComponents([.day], from: oggi, to: calendario.startOfDay(for: data)).day
                        }()
                        
                        let isExpired = (giorniRimasti != nil && giorniRimasti! < 0)
                        
                        let testoScadenza: String = {
                            guard let dataTrovata = articolo.expiryDate, let giorni = giorniRimasti else { return "Senza Data" }
                            if giorni < 0 { return "Expired" }
                            if mostraContoAllaRovescia {
                                if giorni == 0 { return "Today" }
                                else if giorni == 1 { return "Tomorrow" }
                                else { return "-\(giorni)" }
                            } else {
                                let f = DateFormatter()
                                f.dateStyle = .short
                                return f.string(from: dataTrovata)
                            }
                        }()
                        
                        let coloreScadenza: Color = {
                            guard let giorni = giorniRimasti else { return verdeSalvia }
                            return giorni <= 7 ? terracottaBadge : verdeSalvia
                        }()
                        
                        AlimentoCardView(
                            nome: articolo.isLoading ? "Ricerca in corso..." : (articolo.product?.productName ?? "Sconosciuto"),
                            dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                            scadenza: testoScadenza,
                            coloreBadge: coloreScadenza,
                            eScaduto: isExpired,
                            
                            // 🚀 MAGIA: I tastini scompaiono se il prodotto è scaduto!
                            mostraTastini: !isExpired,
                            
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
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
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
            pulisciScadutiVecchi() // 🚀 Pulisce all'avvio
        }
        .onChange(of: scenePhase) { nuovaFase in
            if nuovaFase == .active {
                scannedItems = DataManager.loadItems()
                pulisciScadutiVecchi() // 🚀 Pulisce quando riapri l'app
            }
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
    
    // MARK: - FUNZIONE DI PULIZIA AUTOMATICA
    func pulisciScadutiVecchi() {
        let calendario = Calendar.current
        let oggi = calendario.startOfDay(for: Date())
        var haCancellatoQualcosa = false
        
        scannedItems.removeAll { articolo in
            guard let data = articolo.expiryDate else { return false }
            let giorni = calendario.dateComponents([.day], from: oggi, to: calendario.startOfDay(for: data)).day ?? 0
            
            // 🚀 Se è scaduto da PIÙ di 1 giorno, eliminalo fisicamente
            if giorni < -1 {
                NotificationManager.shared.cancellaNotifica(id: articolo.id)
                haCancellatoQualcosa = true
                return true
            }
            return false
        }
        
        if haCancellatoQualcosa {
            DataManager.saveItems(scannedItems)
        }
    }
    
    // MARK: - MOTORE SCANNER E RETE
    func addProduct(code: String) {
        let prodottoConosciuto = scannedItems.first(where: { $0.barcode == code })?.product
        
        let newItem = ScannedItem(barcode: code, product: prodottoConosciuto, isLoading: prodottoConosciuto == nil)
        idUltimoScansionato = newItem.id
        
        withAnimation { scannedItems.insert(newItem, at: 0) }
        DataManager.saveItems(scannedItems)
        
        if prodottoConosciuto == nil {
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
        } else {
            isOCRScannerShowing = true
        }
    }
    
    // MARK: - MOTORE OCR (MERGE INTELLIGENTE PER DATA)
    func aggiungiDataAlProdotto(data: Date) {
        guard let id = idUltimoScansionato,
              let indexNuovo = scannedItems.firstIndex(where: { $0.id == id }) else {
            isOCRScannerShowing = false
            return
        }
        
        let barcodeScansionato = scannedItems[indexNuovo].barcode
        let calendario = Calendar.current
        let dataNormalizzata = calendario.startOfDay(for: data)
        
        if let indexEsistente = scannedItems.firstIndex(where: {
            $0.id != id &&
            $0.barcode == barcodeScansionato &&
            $0.expiryDate.map({ calendario.startOfDay(for: $0) }) == dataNormalizzata
        }) {
            withAnimation {
                scannedItems[indexEsistente].quantity += 1
                scannedItems.remove(at: indexNuovo)
            }
            NotificationManager.shared.programmaNotifica(per: scannedItems[indexEsistente])
        } else {
            withAnimation {
                scannedItems[indexNuovo].expiryDate = data
            }
            NotificationManager.shared.programmaNotifica(per: scannedItems[indexNuovo])
        }
        
        DataManager.saveItems(scannedItems)
        isOCRScannerShowing = false
        idUltimoScansionato = nil
    }
    
    // MARK: - FUNZIONE ELIMINAZIONE MANUALE
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
