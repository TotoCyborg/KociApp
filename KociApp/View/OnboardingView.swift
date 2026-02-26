//
//  OnboardingView.swift
//  KociApp
//
//  Created by elio koci on 24/02/26.
//

import SwiftUI

struct OnboardingView: View {
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    @State private var paginaCorrente = 0
    @Binding var onboardingCompletato: Bool
    
    // 🚀 MAGIA: Salviamo il nome direttamente nella memoria condivisa dell'app
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    var body: some View {
        ZStack {
            // Sfondo che copre tutto
            colorPanna.ignoresSafeArea()
            
            // 1. LE TUE IMMAGINI CHE SCORRONO
            TabView(selection: $paginaCorrente) {
                Image("slide1")
                    .resizable()
                    .scaledToFit()
                    .tag(0)
                
                Image("slide2")
                    .resizable()
                    .scaledToFit()
                    .tag(1)
                
                Image("slide3")
                    .resizable()
                    .scaledToFit()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            
            // 2. IL TASTO "SALTA" FISSO
            if paginaCorrente < 2 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onboardingCompletato = true
                        }) {
                            Text("Salta")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                                .padding(.trailing, 24)
                        }
                    }
                    Spacer()
                }
            }
            
            // 3. I PALLINI E I CONTROLLI DELLA SCHERMATA FINALE
            VStack {
                Spacer()
                
                // I Pallini Personalizzati
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(paginaCorrente == index ? verdeSalvia : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                // Alziamo i pallini nell'ultima slide per fare spazio al campo di testo
                .padding(.bottom, paginaCorrente == 2 ? 20 : 100)
                
                // 🚀 COMPAIONO SOLO NELL'ULTIMA SLIDE
                if paginaCorrente == 2 {
                    VStack(spacing: 16) {
                        
                        // IL CAMPO DI TESTO PER IL NOME
                        TextField("Come ti chiami?", text: $nomeUtente)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(grigioScuroTesto)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 24)
                            .submitLabel(.done) // Chiude la tastiera premendo invio
                        
                        // IL BOTTONE INIZIA ORA
                        Button(action: {
                            // Quando l'utente clicca, l'onboarding si chiude e il nome è già salvato
                            onboardingCompletato = true
                        }) {
                            Text("Inizia ora")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(verdeSalvia)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.easeInOut, value: paginaCorrente)
    }
}

#Preview {
    OnboardingView(onboardingCompletato: .constant(false))
}
