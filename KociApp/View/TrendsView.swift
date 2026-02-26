//
//  SpesaView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct TrendsView: View {
    
    // Qui salveremo i dati per le due liste
    @State private var articoliScaduti: [ScannedItem] = []
    @State private var articoliSalvati: [ScannedItem] = []
    
    var body: some View {
        ZStack {
            
            Color.gray.opacity(0.05).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - TITOLO GRANDE
                    Text("Trends")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // MARK: - LISTA CIBI SCADUTI
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cibi Scaduti (Sprecati)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                        
                        // Per ora mettiamo un testo segnaposto se la lista è vuota
                        if articoliScaduti.isEmpty {
                            Text("Nessun cibo sprecato! Ottimo lavoro! 🎉")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                        } else {
                            // Qui in futuro metteremo il ForEach per le card degli scaduti
                        }
                    }
                    
                    // MARK: - LINEA DIVISORIA
                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    
                    // MARK: - LISTA CIBI SALVATI
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cibi Salvati (Consumati)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .padding(.horizontal, 24)
                        
                        if articoliSalvati.isEmpty {
                            Text("Non hai ancora registrato cibi consumati.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 24)
                        } else {
                            // Qui in futuro metteremo il ForEach per le card dei salvati
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
    
    // MARK: - LOGICA DATI
    func caricaStorico() {
        // ⚠️ Qui scriveremo la logica per pescare i cibi dallo storico
    }
}

#Preview {
    TrendsView()
}
