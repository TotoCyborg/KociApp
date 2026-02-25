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
    let rossoOggi = Color(red: 0.71, green: 0.47, blue: 0.45)
    
    @State private var mostraSoloInScadenza = true
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    // 1. RIMOSSI I MOCK DATA E AGGIUNTO IL COLLEGAMENTO AI DATI REALI
    @State private var scannedItems: [ScannedItem] = []
    
    // 2. AGGIORNATO IL FILTRO PER LEGGERE GLI SCANNED ITEMS
    var alimentiMostrati: [ScannedItem] {
        if mostraSoloInScadenza {
            // TODO: Qui andrà inserito il filtro del tuo collega per la data di scadenza.
            // Per ora mostriamo tutto, così l'app non si rompe.
            return scannedItems
        } else {
            return scannedItems
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
                        
                        // NOTA: Assicurati di avere una "ImpostazioniView", altrimenti darà errore.
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
                                
                                // TODO: Potremo rendere questo numero dinamico in seguito!
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
                                        // 3. IL CONTATORE ORA LEGGE I DATI REALI
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
                                // 4. ESTRAIAMO I DATI DAGLI SCANNED ITEMS
                                ForEach(alimentiMostrati) { articolo in
                                    DashboardCardView(
                                        nome: articolo.isLoading ? "Caricamento..." : (articolo.product?.productName ?? "Sconosciuto"),
                                        dettaglio: articolo.isLoading ? "Attendere prego" : "\(articolo.quantity) pz • \(articolo.product?.brands ?? "Marca ignota")",
                                        badgeText: "In Dispensa", // Temporaneo fino al merge del collega
                                        badgeColor: verdeSalvia // Temporaneo fino al merge del collega
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden) // Opzionale: nasconde la barra di scorrimento laterale
                }
            }
            // 5. CARICHIAMO I DATI QUANDO LA SCHERMATA APPARE
            .onAppear {
                scannedItems = DataManager.loadItems()
            }
        }
    }
}

// supporto
// supporto
struct DashboardCardView: View {
    var nome, dettaglio, badgeText: String
    var badgeColor: Color
    
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Icona (Allineata alle dimensioni esatte della Dispensa: 50x50)
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
                    .font(.system(size: 16, weight: .bold)) // Font a 16 come in Dispensa
                    .foregroundColor(grigioScuroTesto)
                    .lineLimit(1)
                
                Text(dettaglio)
                    .font(.system(size: 13, weight: .medium)) // Aggiunto weight .medium
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Badge Scadenza ESATTAMENTE identico alla Dispensa
            VStack(alignment: .trailing) {
                Text(badgeText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(badgeColor)
                    .cornerRadius(12)
            }
        }
        .padding() // Usa il padding standard come in Dispensa
        .background(Color.white)
        .cornerRadius(20) // Corner radius a 20 anziché 24
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
#Preview {
    DashboardView()
}
