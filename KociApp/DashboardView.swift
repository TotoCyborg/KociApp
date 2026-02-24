//
//  DashboardView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//
import SwiftUI

// dati
// definizione alimento
struct Alimento: Identifiable {
    let id = UUID()
    let nome: String
    let dettaglio: String
    let badgeText: String
    let badgeColor: Color
    let inScadenza: Bool
}

struct DashboardView: View {
    // colori
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let terracottaChiaro = Color(red: 0.73, green: 0.55, blue: 0.49)
    let rossoOggi = Color(red: 0.71, green: 0.47, blue: 0.45) // #B67774
    
    @State private var mostraSoloInScadenza = true
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    // esempio (mock data)
    let tuttiGliAlimenti = [
        Alimento(nome: "Petto di Pollo", dettaglio: "300g • Confezione aperta", badgeText: "Oggi", badgeColor: Color(red: 0.71, green: 0.47, blue: 0.45), inScadenza: true),
        Alimento(nome: "Latte Fresco", dettaglio: "1 Litro • Intero", badgeText: "2 gg", badgeColor: Color(red: 0.72, green: 0.49, blue: 0.44), inScadenza: true),
        Alimento(nome: "Yogurt Greco", dettaglio: "2 vasetti • Mirtilli", badgeText: "5 gg", badgeColor: Color(red: 0.48, green: 0.59, blue: 0.49), inScadenza: false),
        Alimento(nome: "Zucchine Bio", dettaglio: "500g • Cassetto verdure", badgeText: "7 gg", badgeColor: Color(red: 0.48, green: 0.59, blue: 0.49), inScadenza: false)
    ]
    
    // filtro lista
    var alimentiMostrati: [Alimento] {
        if mostraSoloInScadenza == true {
            return tuttiGliAlimenti.filter { alimento in alimento.inScadenza == true }
        } else {
            return tuttiGliAlimenti
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colorPanna.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // header fisso
                    HStack {
                        Text(nomeUtente.isEmpty ? "Benvenuto!" : "Ciao \(nomeUtente)!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(grigioScuroTesto)
                        Spacer()
                        NavigationLink(destination: ImpostazioniView()) {
                            Circle().fill(terracottaChiaro).frame(width: 48, height: 48)
                                .overlay(
                                    Text(nomeUtente.isEmpty ? "?" : String(nomeUtente.prefix(1)).uppercased())
                                        .foregroundColor(.white).bold()
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                    .background(colorPanna) // copertura elementi che scorrono
                    
                    // scroll
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // gamification
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sfida della Settimana")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(grigioScuroTesto)
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.1)).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 6).fill(verdeSalvia).frame(width: geometry.size.width * 0.8, height: 8)
                                    }
                                }.frame(height: 8)
                                
                                Text("8 su 10 alimenti salvati")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 4)
                            }
                            .padding(.top, 20)
                            
                            // pills
                            HStack(spacing: 12) {
                                Text("In scadenza")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(mostraSoloInScadenza ? .white : verdeSalvia)
                                    .padding(.horizontal, 18).padding(.vertical, 10)
                                    .background(mostraSoloInScadenza ? verdeSalvia : Color.white)
                                    .cornerRadius(24)
                                    .onTapGesture { withAnimation { mostraSoloInScadenza = true } }
                                
                                Text("Tutto")
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
                                        Text("\(alimentiMostrati.count)").font(.system(size: 54, weight: .bold, design: .rounded)).foregroundColor(verdeSalvia)
                                        Text(mostraSoloInScadenza ? "Da Salvare" : "Totali").font(.system(size: 16, weight: .bold)).foregroundColor(verdeSalvia)
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 40)
                            
                            // titolo lista
                            Text(mostraSoloInScadenza ? "In scadenza a breve" : "Tutti gli alimenti")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(grigioScuroTesto)
                                .padding(.bottom, 16)
                            
                            // card
                            VStack(spacing: 12) {
                                ForEach(alimentiMostrati) { alimento in
                                    DashboardCardView(nome: alimento.nome, dettaglio: alimento.dettaglio, badgeText: alimento.badgeText, badgeColor: alimento.badgeColor)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
}

// supporto
struct DashboardCardView: View {
    var nome, dettaglio, badgeText: String
    var badgeColor: Color
    
    // Riprendiamo il tuo verde per abbinarlo
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    var body: some View {
        HStack(spacing: 16) {
            
            // --- ECCO LA NUOVA ICONA ---
            ZStack {
                // Sfondo del quadratino (verde chiaro trasparente)
                RoundedRectangle(cornerRadius: 14)
                    .fill(verdeSalvia.opacity(0.15))
                
                // L'icona al centro (verde salvia pieno)
                Image(systemName: "fork.knife") // Prova anche "bag.fill" o "takeoutbox.fill"
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(verdeSalvia)
            }
            .frame(width: 56, height: 56)
            // ---------------------------
            
            VStack(alignment: .leading) {
                Text(nome).font(.system(size: 17, weight: .bold))
                Text(dettaglio).font(.system(size: 13)).foregroundColor(.gray) // corretto .font
            }
            Spacer()
            
            Text(badgeText)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(badgeColor)
                .cornerRadius(12)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(24)
    }
}
#Preview {
    DashboardView()
}
