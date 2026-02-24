//
//  DispensaView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

// modello dati
struct ArticoloDispensa: Identifiable {
    let id = UUID()
    let nome: String
    let dettaglio: String
    let scadenza: String
    let coloreBadge: Color
}

struct DispensaView: View {
    // colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracottaBadge = Color(red: 0.72, green: 0.49, blue: 0.44)
    let rossoOggi = Color(red: 0.71, green: 0.47, blue: 0.45)
    
    // variabile per ricerca
    @State private var testoRicerca: String = ""
    
    // la lista di alimenti mock - TRADOTTI PER LO SCHERMO
    let tuttiGliArticoli = [
        ArticoloDispensa(nome: "Chicken Breast", dettaglio: "300g • Opened package", scadenza: "Today", coloreBadge: Color(red: 0.71, green: 0.47, blue: 0.45)),
        ArticoloDispensa(nome: "Fresh Milk", dettaglio: "1 Liter • Whole", scadenza: "2 days", coloreBadge: Color(red: 0.72, green: 0.49, blue: 0.44)),
        ArticoloDispensa(nome: "Greek Yogurt", dettaglio: "2 cups • Blueberry", scadenza: "5 days", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Organic Zucchini", dettaglio: "500g • Crisper drawer", scadenza: "7 days", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Large Eggs", dettaglio: "4 left • Cage-free", scadenza: "12 days", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Parmesan Cheese", dettaglio: "300g • Block", scadenza: "25 days", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49))
    ]
    
    // match ricerca
    var articoliFiltrati: [ArticoloDispensa] {
        if testoRicerca.isEmpty {
            return tuttiGliArticoli
        } else {
            return tuttiGliArticoli.filter { $0.nome.lowercased().contains(testoRicerca.lowercased()) }
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
                            print("Add new item") // Messaggio console
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
                
                // lista scroll
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(articoliFiltrati) { articolo in
                            DispensaCardView(
                                nome: articolo.nome,
                                dettaglio: articolo.dettaglio,
                                scadenza: articolo.scadenza,
                                coloreBadge: articolo.coloreBadge
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// card alimenti
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
