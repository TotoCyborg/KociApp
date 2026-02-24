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
    
    // la lista di alimenti mock
    let tuttiGliArticoli = [
        ArticoloDispensa(nome: "Petto di Pollo", dettaglio: "300g • Confezione aperta", scadenza: "Oggi", coloreBadge: Color(red: 0.71, green: 0.47, blue: 0.45)),
        ArticoloDispensa(nome: "Latte Fresco", dettaglio: "1 Litro • Intero", scadenza: "2 gg", coloreBadge: Color(red: 0.72, green: 0.49, blue: 0.44)),
        ArticoloDispensa(nome: "Yogurt Greco", dettaglio: "2 vasetti • Mirtilli", scadenza: "5 gg", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Zucchine Bio", dettaglio: "500g • Cassetto verdure", scadenza: "7 gg", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Uova Grandi", dettaglio: "4 rimaste • Allev. a terra", scadenza: "12 gg", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49)),
        ArticoloDispensa(nome: "Parmigiano Reggiano", dettaglio: "300g • Pezzo intero", scadenza: "25 gg", coloreBadge: Color(red: 0.48, green: 0.59, blue: 0.49))
    ]
    
    // match ricerca
    var articoliFiltrati: [ArticoloDispensa] {
        if testoRicerca.isEmpty {
            return tuttiGliArticoli
        } else {
            // no caps sensitive
            return tuttiGliArticoli.filter { $0.nome.lowercased().contains(testoRicerca.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // header
                VStack(spacing: 16) {
                    
                    // "dispensa" e +
                    HStack {
                        Text("Dispensa")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                            .padding(.top, 30)
                                    .padding(.horizontal, 2)
                        
                        Spacer()
                        
                        Button(action: {
                            print("Aggiungi nuovo alimento")
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.top, 30)
                                        .padding(.horizontal, 2)
                        }
                    }
                    
                    // barra di ricerca
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Cerca...", text: $testoRicerca)
                            .foregroundColor(grigioScuroTesto)
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.15)) // grigio chiaro semitrasparente
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // lista scroll
                ScrollView {
                    VStack(spacing: 16) {
                        // foreach per i prodotti
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
                    .padding(.bottom, 40) // spazio per la tab bar
                }
            }
        }
    }
}

// card alimenti
import SwiftUI

struct DispensaCardView: View {
    var nome: String
    var dettaglio: String
    var scadenza: String
    var coloreBadge: Color
    
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let grigioIcona = Color(red: 0.35, green: 0.36, blue: 0.41)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49) // Aggiunto per l'icona
    
    var body: some View {
        HStack(spacing: 16) {
            
            // NUOVO BLOCCO: Icona dispensa al posto del quadratino grigio
            ZStack {
                // Sfondo verde chiaro con la stessa curvatura di prima
                RoundedRectangle(cornerRadius: 12)
                    .fill(verdeSalvia.opacity(0.15))
                
                // Simbolo nativo Apple
                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(verdeSalvia)
            }
            .frame(width: 50, height: 50)
            // -----------------------------------------------------------
            
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
