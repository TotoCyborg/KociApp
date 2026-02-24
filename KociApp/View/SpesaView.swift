//
//  SpesaView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

// Modello dati (lasciamo i nomi in italiano come preferisci)
struct ArticoloLista: Identifiable {
    let id = UUID()
    let nome: String
    let quantita: String
    var isPreso: Bool
    var sottotitolo: String = ""
}

struct SpesaView: View {
    // Colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    // --- LOGICA DI STATO ---
    @State private var testoNuovoArticolo: String = ""
    @State private var listaArticoli: [ArticoloLista] = [
        ArticoloLista(nome: "Fresh Milk", quantita: "x2", isPreso: false),
        ArticoloLista(nome: "Organic Eggs (6pk)", quantita: "x1", isPreso: false),
        ArticoloLista(nome: "Genovese Pesto", quantita: "x1", isPreso: false, sottotitolo: "Out of stock in pantry")
    ]
    
    // Funzione per aggiungere l'articolo
    func aggiungiArticolo() {
        // Se il testo è vuoto, non fare nulla
        guard !testoNuovoArticolo.isEmpty else { return }
        
        let nuovo = ArticoloLista(nome: testoNuovoArticolo, quantita: "x1", isPreso: false)
        
        withAnimation {
            listaArticoli.insert(nuovo, at: 0) // Lo mette in cima
            testoNuovoArticolo = "" // Pulisce il campo di testo
        }
    }

    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Titolo
                VStack(alignment: .leading) {
                    Text("Your shopping list")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(grigioScuroTesto)
                        .padding(.top, 42)
                        .padding(.bottom, 15)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorPanna)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // BARRA DI INSERIMENTO
                        HStack {
                            Button(action: aggiungiArticolo) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(verdeSalvia)
                                    .font(.title3)
                            }
                            
                            // TextField aggiornato con onSubmit per la tastiera
                            TextField("What else do you need?", text: $testoNuovoArticolo)
                                .foregroundColor(grigioScuroTesto)
                                .submitLabel(.done) // CORRETTO: .done invece di .add
                                .onSubmit {
                                    aggiungiArticolo()
                                }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // LISTA ARTICOLI
                        VStack(spacing: 0) {
                            ForEach(listaArticoli) { articolo in
                                SpesaRigaView(
                                    nome: articolo.nome,
                                    sottotitolo: articolo.sottotitolo,
                                    quantita: articolo.quantita,
                                    isPreso: articolo.isPreso
                                )
                                
                                if articolo.id != listaArticoli.last?.id {
                                    Divider().padding(.leading, 50)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        
                        // Bottone finale
                        Button(action: {
                            print("Saving to pantry...")
                        }) {
                            Text("Add items to Pantry")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(verdeSalvia)
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 5)
                }
            }
        }
    }
}

// Riga della spesa (Sposta isPreso in una variabile che la view può modificare)
struct SpesaRigaView: View {
    var nome: String
    var sottotitolo: String
    var quantita: String
    @State var isPreso: Bool
    
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracotta = Color(red: 0.72, green: 0.49, blue: 0.44)
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                withAnimation { isPreso.toggle() }
            }) {
                Image(systemName: isPreso ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isPreso ? verdeSalvia : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nome)
                    .font(.system(size: 16, weight: .semibold))
                    .strikethrough(isPreso)
                    .foregroundColor(isPreso ? .gray : .black)
                
                if !sottotitolo.isEmpty {
                    Text(sottotitolo)
                        .font(.system(size: 12))
                        .foregroundColor(terracotta)
                }
            }
            Spacer()
            
            Text(quantita)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(verdeSalvia)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(verdeSalvia.opacity(0.15))
                .cornerRadius(12)
        }
        .padding(16)
    }
}
#Preview {
    SpesaView()
}
