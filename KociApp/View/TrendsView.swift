//
//  TrendsView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct TrendsView: View {
    
    // colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let terracottaChiaro = Color(red: 0.73, green: 0.55, blue: 0.49)
    
    // 📦 Le nostre due liste di storico
    @State private var articoliScaduti: [ScannedItem] = []
    @State private var articoliSalvati: [ScannedItem] = []
    
    var body: some View {
        ZStack {
            // Sfondo grigio chiaro uguale al resto dell'app
            colorPanna.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - TITOLO GRANDE
                    Text("Trends")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // MARK: - LISTA CIBI SCADUTI (IN ALTO)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cibi Scaduti")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(terracottaChiaro)
                            .padding(.horizontal, 24)
                        
                        if articoliScaduti.isEmpty {
                            Text("Nessun cibo sprecato! Ottimo lavoro! 🎉")
                                .font(.subheadline)
                                .foregroundColor(terracottaChiaro)
                                .padding(.horizontal, 24)
                        } else {
                            ForEach(articoliScaduti, id: \.id) { articolo in
                                TrendCardView(articolo: articolo, isScaduto: true)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                    
                    // MARK: - LINEA DIVISORIA
                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    
                    // MARK: - LISTA CIBI SALVATI (IN BASSO)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cibi Salvati")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(verdeSalvia)
                            .padding(.horizontal, 24)
                        
                        if articoliSalvati.isEmpty {
                            Text("Non hai ancora consumato cibi!")
                                .font(.subheadline)
                                .foregroundColor(verdeSalvia)
                                .padding(.horizontal, 24)
                        } else {
                            ForEach(articoliSalvati, id: \.id) { articolo in
                                TrendCardView(articolo: articolo, isScaduto: false)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .onAppear {
            caricaStorico()
        }
    }
    
    // MARK: - LOGICA DI CARICAMENTO
    func caricaStorico() {
        articoliScaduti = DataManager.loadScaduti()
        articoliSalvati = DataManager.loadSalvati()
        print("📊 Pagina Trends aperta! Caricati -> Scaduti: \(articoliScaduti.count) | Salvati: \(articoliSalvati.count)")
    }
}

// MARK: - CARD SEMPLIFICATA PER LO STORICO
struct TrendCardView: View {
    
    //colori
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracottaChiaro = Color(red: 0.73, green: 0.55, blue: 0.49)
    
    var articolo: ScannedItem
    var isScaduto: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(articolo.product?.productName ?? "Prodotto Sconosciuto")
                    .font(.headline)
                
                Text("\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Un bel "bollino" colorato per far capire subito lo stato
            Text(isScaduto ? "Sprecato" : "Consumato")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isScaduto ? terracottaChiaro.opacity(0.15) : verdeSalvia.opacity(0.15))
                .foregroundColor(isScaduto ? terracottaChiaro : verdeSalvia)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    TrendsView()
}
