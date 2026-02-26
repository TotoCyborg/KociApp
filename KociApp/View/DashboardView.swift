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
    
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    // VARIABILI DI MEMORIA PER LA GAMIFICATION
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @AppStorage("lastStreakUpdate") private var lastStreakUpdate: Double = 0
    
    @State private var scannedItems: [ScannedItem] = []
    
    @Environment(\.scenePhase) var scenePhase
    
    // FILTRO INTELLIGENTE E ORDINAMENTO (Mostra SEMPRE E SOLO quelli in scadenza entro 7 giorni)
    var alimentiMostrati: [ScannedItem] {
        let filtrati = scannedItems.filter { articolo in
            if let dataTrovata = articolo.expiryDate {
                let calendario = Calendar.current
                let oggi = calendario.startOfDay(for: Date())
                let giornoScadenza = calendario.startOfDay(for: dataTrovata)
                let componenti = calendario.dateComponents([.day], from: oggi, to: giornoScadenza)
                let giorniRimasti = componenti.day ?? 0
                
                // Nasconde i prodotti già scaduti (< 0)
                if giorniRimasti < 0 { return false }
                
                // Mostra SOLO quelli che scadono entro 7 giorni
                return giorniRimasti <= 7
            } else {
                // Se non ha data, non è un'emergenza, quindi non lo mostriamo nella Dashboard
                return false
            }
        }
        
        return filtrati.sorted { (item1, item2) -> Bool in
            if let date1 = item1.expiryDate, let date2 = item2.expiryDate {
                return date1 < date2
            } else if item1.expiryDate != nil {
                return true
            } else if item2.expiryDate != nil {
                return false
            }
            return false
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colorPanna.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // header fisso pulito (Senza icona account)
                    HStack {
                        Text(nomeUtente.isEmpty ? "Welcome!" : "Hello \(nomeUtente)!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .background(colorPanna)
                    
                    // scroll
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // SEZIONE GAMIFICATION
                            VStack(alignment: .leading, spacing: 6) {
                                
                                let settimanaCorrente = (currentStreak == 0) ? 1 : ((currentStreak - 1) / 7) + 1
                                let giorniNelCiclo = (currentStreak == 0) ? 0 : ((currentStreak - 1) % 7) + 1
                                
                                HStack {
                                    Text("Zero Waste Streak 🔥")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(grigioScuroTesto)
                                    
                                    // BOTTONE MAGICO (Per testare i cicli! Rimuovere prima di pubblicare)
                                    Button(action: {
                                        currentStreak += 1
                                    }) {
                                        Image(systemName: "wand.and.stars")
                                            .font(.system(size: 16))
                                            .foregroundColor(.purple)
                                    }
                                    
                                    Spacer()
                                    
                                    // PILLOLA DELLA SETTIMANA
                                    Text("Week \(settimanaCorrente)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(currentStreak > 0 ? verdeSalvia : rossoOggi)
                                        .clipShape(Capsule())
                                }
                                
                                // Barra di Progresso
                                GeometryReader { geometry in
                                    let progresso = CGFloat(giorniNelCiclo) / 7.0
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(currentStreak > 0 ? verdeSalvia : rossoOggi)
                                            .frame(width: geometry.size.width * (currentStreak == 0 ? 0.02 : progresso), height: 8)
                                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progresso)
                                    }
                                }.frame(height: 8)
                                
                                // I GIORNI E LA MOTIVAZIONE
                                HStack {
                                    Text("\(giorniNelCiclo) / 7 Days")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(currentStreak > 0 ? verdeSalvia : rossoOggi)
                                    
                                    Spacer()
                                    
                                    Text(testoMotivazionale(giorni: giorniNelCiclo))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                            // cerchio con numero di alimenti
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle().stroke(verdeSalvia, lineWidth: 28).frame(width: 200, height: 200)
                                    VStack(spacing: -2) {
                                        Text("\(alimentiMostrati.count)")
                                            .font(.system(size: 54, weight: .bold, design: .rounded))
                                            .foregroundColor(verdeSalvia)
                                        Text("To Save")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(verdeSalvia)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                            
                            // titolo lista
                            Text("Expiring soon")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.bottom, 16)
                            
                            // card
                            VStack(spacing: 12) {
                                ForEach(alimentiMostrati) { articolo in
                                    
                                    let giorniRimasti: Int? = {
                                        guard let dataTrovata = articolo.expiryDate else { return nil }
                                        let calendario = Calendar.current
                                        return calendario.dateComponents([.day], from: calendario.startOfDay(for: Date()), to: calendario.startOfDay(for: dataTrovata)).day
                                    }()
                                    
                                    let isExpired = (giorniRimasti != nil && giorniRimasti! < 0)
                                    
                                    let testoScadenza: String = {
                                        if let giorni = giorniRimasti {
                                            if giorni < 0 { return "Expired" }
                                            else if giorni == 0 { return "Today" }
                                            else if giorni == 1 { return "Tomorrow" }
                                            else { return "-\(giorni)" }
                                        }
                                        return "No Date"
                                    }()
                                    
                                    let coloreScadenza: Color = {
                                        if let giorni = giorniRimasti {
                                            return giorni <= 7 ? terracottaChiaro : verdeSalvia
                                        }
                                        return verdeSalvia
                                    }()
                                    
                                    AlimentoCardView(
                                        nome: articolo.isLoading ? "Loading..." : (articolo.product?.productName ?? "Unknown"),
                                        dettaglio: articolo.isLoading ? "Please wait" : "\(articolo.quantity) pcs • \(articolo.product?.brands ?? "Unknown")",
                                        scadenza: testoScadenza,
                                        coloreBadge: coloreScadenza,
                                        eScaduto: isExpired,
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
                aggiornaStreak()
            }
            .onChange(of: scenePhase) { nuovaFase in
                if nuovaFase == .active {
                    scannedItems = DataManager.loadItems()
                    aggiornaStreak()
                }
            }
        }
    }
    
    // MARK: - MOTORE DELLA GAMIFICATION
    func aggiornaStreak() {
        let calendario = Calendar.current
        let oggi = calendario.startOfDay(for: Date())
        
        if lastStreakUpdate == 0 {
            lastStreakUpdate = oggi.timeIntervalSince1970
            return
        }
        
        let cEQualcosaDiScaduto = scannedItems.contains { articolo in
            guard let dataScadenza = articolo.expiryDate else { return false }
            return calendario.startOfDay(for: dataScadenza) < oggi
        }
        
        if cEQualcosaDiScaduto {
            currentStreak = 0
            lastStreakUpdate = oggi.timeIntervalSince1970
        } else {
            let ultimaData = Date(timeIntervalSince1970: lastStreakUpdate)
            let inizioUltimaData = calendario.startOfDay(for: ultimaData)
            
            if let giorniPassati = calendario.dateComponents([.day], from: inizioUltimaData, to: oggi).day, giorniPassati > 0 {
                currentStreak += giorniPassati
                lastStreakUpdate = oggi.timeIntervalSince1970
            }
        }
    }
    
    func testoMotivazionale(giorni: Int) -> String {
        if currentStreak == 0 {
            return "Oh no! Let's start over!"
        } else if giorni == 7 {
            return "Perfect week! 🎉"
        } else if giorni >= 4 {
            return "Halfway there, keep going!"
        } else {
            return "Great start! 👏"
        }
    }
}

#Preview {
    DashboardView()
}
