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
    
    @State private var paginaCorrente = 0
    @Binding var onboardingCompletato: Bool
    
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
            // IL TRUCCO: "never" spegne i pallini automatici di Apple che erano troppo bassi
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)
            
            // 2. IL TASTO "SALTA" FISSO (Ora scompare all'ultima slide!)
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
            
            // 3. I NOSTRI PALLINI E IL BOTTONE SOTTO CONTROLLO MANUALE
            VStack {
                Spacer() // Spinge questa roba verso il basso
                
                // I Pallini Personalizzati
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(paginaCorrente == index ? verdeSalvia : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                // Ecco il controllo al millimetro!
                // Se vuoi alzarli di più, aumenta il 30 (nella slide 3) o il 100 (slide 1 e 2)
                .padding(.bottom, paginaCorrente == 2 ? 30 : 100)
                
                // Il Bottone (appare solo alla fine)
                if paginaCorrente == 2 {
                    Button(action: {
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
            }
        }
    }
}

#Preview {
    OnboardingView(onboardingCompletato: .constant(false))
}
