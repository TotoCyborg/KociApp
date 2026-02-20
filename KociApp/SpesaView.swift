//
//  SpesaView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct SpesaView: View {
    //colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    var body: some View {
        ZStack {
            // sfondo
            colorPanna.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // titolo fisso
                VStack(alignment: .leading) {
                    Text("La tua lista della spesa")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(grigioScuroTesto)
                        .padding(.top, 42) // Il tuo "pochissimo" più basso
                        .padding(.bottom, 15)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(colorPanna) // Serve a coprire gli elementi che salgono
                
                // scroll
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // barra di inserimento
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(verdeSalvia)
                            
                            Text("Cos'altro ti manca?")
                                .foregroundColor(.gray)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        
                        // blocco bianco
                        VStack(spacing: 0) {
                            SpesaRigaView(nome: "Latte Fresco", quantita: "x2", isPreso: false)
                            Divider().padding(.leading, 50)
                            
                            SpesaRigaView(nome: "Uova Bio (6pz)", quantita: "x1", isPreso: false)
                            Divider().padding(.leading, 50)
                            
                            SpesaRigaView(nome: "Pesto alla Genovese", sottotitolo: "Terminato in dispensa", quantita: "x1", isPreso: false)
                            Divider().padding(.leading, 50)
                            
                            SpesaRigaView(nome: "Insalata in busta", quantita: "x1", isPreso: true)
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        
                        // bottone aggiungi
                        Button(action: {
                            print("Aggiunta articoli in corso...")
                        }) {
                            Text("Aggiungi articoli in Dispensa")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(verdeSalvia)
                                .cornerRadius(16)
                        }
                        .padding(.bottom, 40) // spazio
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 5)
                }
            }
        
        }
    }
}

struct SpesaRigaView: View {
    var nome: String
    var sottotitolo: String = ""
    var quantita: String
    @State var isPreso: Bool
    
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracotta = Color(red: 0.72, green: 0.49, blue: 0.44)
    
    var body: some View {
        HStack(spacing: 16) {
            // tasto verde check
            Button(action: {
                withAnimation { isPreso.toggle() }
            }) {
                Image(systemName: isPreso ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isPreso ? verdeSalvia : .gray)
            }
            
            // testi
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
            
            // quantità
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
