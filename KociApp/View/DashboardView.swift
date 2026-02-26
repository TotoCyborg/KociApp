//
//  DashboardView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct DashboardView: View {
    // colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let terracottaChiaro = Color(red: 0.73, green: 0.55, blue: 0.49)
    
    @State private var mostraSoloInScadenza = true
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    @State private var scannedItems: [ScannedItem] = []
    
    // 🚀 FILTRO INTELLIGENTE E ORDINAMENTO
    var alimentiMostrati: [ScannedItem] {
        let filtrati = scannedItems.filter { articolo in
            
            // Se il prodotto ha una data di scadenza...
            if let dataTrovata = articolo.expiryDate {
                let calendario = Calendar.current
                let oggi = calendario.startOfDay(for: Date())
                let giornoScadenza = calendario.startOfDay(for: dataTrovata)
                let componenti = calendario.dateComponents([.day], from: oggi, to: giornoScadenza)
                let giorniRimasti = componenti.day ?? 0
                
                // 1. Se è GIA' SCADUTO (< 0 giorni), non lo mostriamo
                if giorniRimasti < 0 {
                    return false
                }
                
                // 2. Filtro "Expiring"
                if mostraSoloInScadenza {
                    return giorniRimasti <= 7
                }
                
                // 3. Filtro "All"
                return true
                
            } else {
                return !mostraSoloInScadenza
            }
        }
        
        // 🚀 ORDINAMENTO: I prodotti che scadono prima vanno in cima!
        return filtrati.sorted { (item1, item2) -> Bool in
            if let date1 = item1.expiryDate, let date2 = item2.expiryDate {
                return date1 < date2 // Se entrambi hanno la data, vince chi scade prima
            } else if item1.expiryDate != nil {
                return true  // Se solo item1 ha la data, vince lui e va sopra
            } else if item2.expiryDate != nil {
                return false // Se solo item2 ha la data, vince lui
            }
            return false // Se nessuno dei due ha la data, restano dove sono
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colorPanna.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // header fisso
                    HStack {
                        Text(nomeUtente.isEmpty ? "Welcome!" : "Hello \(nomeUtente)!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                        Spacer()
                        
                        NavigationLink(destination: Text("Impostazioni (In arrivo)")) {
                            Circle().fill(terracottaChiaro).frame(width: 48, height: 48)
                                .overlay(
                                    Group {
                                        if nomeUtente.isEmpty {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        } else {
                                            Text(String(nomeUtente.prefix(1)).uppercased())
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .background(colorPanna)
                    
                    // scroll
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // gamification
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Weekly Challenge")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(grigioScuroTesto)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 6).fill(verdeSalvia).frame(width: geometry.size.width * 0.8, height: 8)
                                    }
                                }.frame(height: 8)
                                
                                Text("8 out of 10 items saved")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 4)
                            }
                            .padding(.top, 20)
                            
                            // pills
                            HStack(spacing: 12) {
                                Text("Expiring")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(mostraSoloInScadenza ? .white : verdeSalvia)
                                    .padding(.horizontal, 18).padding(.vertical, 10)
                                    .background(mostraSoloInScadenza ? verdeSalvia : Color.white)
                                    .cornerRadius(24)
                                    .onTapGesture { withAnimation { mostraSoloInScadenza = true } }
                                
                                Text("All")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(!mostraSoloInScadenza ? .white : verdeSalvia)
                                    .padding(.horizontal, 18).padding(.vertical, 10)
                                    .background(!mostraSoloInScadenza ? verdeSalvia : Color.white)
                                    .cornerRadius(24)
                                    .onTapGesture { withAnimation { mostraSoloInScadenza = false } }
                            }
                            .padding(.top, 25)

                            // cerchio con numero di alimenti
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle().stroke(verdeSalvia, lineWidth: 28).frame(width: 200, height: 200)
                                    VStack(spacing: -2) {
                                        Text("\(alimentiMostrati.count)")
                                            .font(.system(size: 54, weight: .bold, design: .rounded))
                                            .foregroundColor(verdeSalvia)
                                        Text(mostraSoloInScadenza ? "To Save" : "Total")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(verdeSalvia)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                            
                            // titolo lista
                            Text(mostraSoloInScadenza ? "Expiring soon" : "All food items")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.bottom, 16)
                            
                            // card
                            VStack(spacing: 12) {
                                ForEach(alimentiMostrati) { articolo in
                                    
                                    // 1. Calcoliamo i giorni di differenza
                                    let giorniRimasti: Int? = {
                                        guard let dataTrovata = articolo.expiryDate else { return nil }
                                        let calendario = Calendar.current
                                        let oggi = calendario.startOfDay(for: Date())
                                        let giornoScadenza = calendario.startOfDay(for: dataTrovata)
                                        return calendario.dateComponents([.day], from: oggi, to: giornoScadenza).day
                                    }()
                                    
                                    // 2. Testo in stile conto alla rovescia
                                    let testoScadenza: String = {
                                        if let giorni = giorniRimasti {
                                            if giorni < 0 {
                                                return "Expired"
                                            } else if giorni == 0 {
                                                return "Today"
                                            } else if giorni == 1 {
                                                return "Tomorrow"
                                            } else {
                                                return "-\(giorni)"
                                            }
                                        }
                                        return "No Date"
                                    }()
                                    
                                    // 3. Assegniamo il colore
                                    let coloreScadenza: Color = {
                                        if let giorni = giorniRimasti {
                                            return giorni <= 7 ? terracottaChiaro : verdeSalvia
                                        }
                                        return verdeSalvia
                                    }()
                                    
                                    // COMPONENTE CONDIVISO
                                    AlimentoCardView(
                                        nome: articolo.isLoading ? "Loading..." : (articolo.product?.productName ?? "Unknown"),
                                        dettaglio: articolo.isLoading ? "Please wait" : "\(articolo.quantity) pcs • \(articolo.product?.brands ?? "Unknown")",
                                        scadenza: testoScadenza,
                                        coloreBadge: coloreScadenza,
                                        mostraTastini: false
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .onAppear {
                scannedItems = DataManager.loadItems()
            }
        }
    }
}

#Preview {
    DashboardView()
}
