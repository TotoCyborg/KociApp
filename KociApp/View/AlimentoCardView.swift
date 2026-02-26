//
//  AlimentoCardView.swift
//  KociApp_Grafica
//
//  Created by Toto La Piana on 25/02/26.
//

import SwiftUI

struct AlimentoCardView: View {
    var nome: String
    var dettaglio: String
    var scadenza: String
    var coloreBadge: Color
    
    // 🚀 NUOVO PARAMETRO: Dice alla card se deve "arrossire"
    var eScaduto: Bool = false
    
    // Variabili per i tastini (opzionali)
    var mostraTastini: Bool = false
    var quantita: Int = 1
    var aumentaQuantita: (() -> Void)? = nil
    var diminuisciQuantita: (() -> Void)? = nil
    
    // Colori centralizzati esistenti
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    // 🎨 NUOVI COLORI PER LO STATO SCADUTO
    // Un rosso scuro elegante per il testo del titolo
    let rossoMattoneTesto = Color(red: 0.6, green: 0.2, blue: 0.2)
    // Un bianco appena rosato per lo sfondo (molto soft)
    let sfondoRosatoSoft = Color(red: 1.0, green: 0.97, blue: 0.97)
    // Un rosso vivo ma trasparente per l'alone luminoso
    let ombraRossaGlow = Color.red.opacity(0.25)
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Icona Standard
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(verdeSalvia.opacity(0.15))
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(verdeSalvia)
            }
            .frame(width: 50, height: 50)
            
            // Testi
            VStack(alignment: .leading, spacing: 4) {
                Text(nome)
                    .font(.system(size: 16, weight: .bold))
                    // 🎨 Il colore del testo cambia se è scaduto
                    .foregroundColor(eScaduto ? rossoMattoneTesto : grigioScuroTesto)
                    .lineLimit(1)
                
                Text(dettaglio)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Colonna di Destra (Badge + Eventuali Tastini)
            VStack(alignment: .trailing, spacing: 12) {
                Text(scadenza)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(coloreBadge)
                    .cornerRadius(12)
                
                // Mostra i tastini SOLO se richiesto (nella Dispensa)
                if mostraTastini {
                    HStack(spacing: 8) {
                        Button(action: { diminuisciQuantita?() }) {
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
                        
                        Button(action: { aumentaQuantita?() }) {
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
        }
        .padding()
        // 🎨 SFONDO DINAMICO: Bianco se ok, Rosato se scaduto
        .background(eScaduto ? sfondoRosatoSoft : Color.white)
        .cornerRadius(20)
        // 🎨 OMBRA DINAMICA: Nera soft se ok, Rossa glow se scaduto
        .shadow(
            color: eScaduto ? ombraRossaGlow : .black.opacity(0.03),
            radius: eScaduto ? 8 : 5, // Ombra un po' più ampia se scaduto
            x: 0,
            y: 2
        )
    }
}

// Preview per testare l'effetto (puoi cancellarla dopo)
#Preview {
    VStack {
        AlimentoCardView(nome: "Latte Fresco (Buono)", dettaglio: "1 pz", scadenza: "-3 days", coloreBadge: .orange, eScaduto: false)
        AlimentoCardView(nome: "Yogurt (Scaduto)", dettaglio: "2 pz", scadenza: "Expired", coloreBadge: .red, eScaduto: true)
    }
    .padding()
    .background(Color(red: 0.96, green: 0.95, blue: 0.92))
}
