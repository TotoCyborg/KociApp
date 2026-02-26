//
//  AlimentoCardView.swift
//  KociApp
//
//  Created by Salvatore Rita La Piana on 26/02/26.
//

import SwiftUI

struct AlimentoCardView: View {
    var nome: String
    var dettaglio: String
    var scadenza: String
    var coloreBadge: Color
    
    // Variabili per i tastini (opzionali per la Dashboard)
    var mostraTastini: Bool = false
    var quantita: Int = 1
    var aumentaQuantita: (() -> Void)? = nil
    var diminuisciQuantita: (() -> Void)? = nil
    
    // Colori centralizzati
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
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
                    .foregroundColor(grigioScuroTesto)
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
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
