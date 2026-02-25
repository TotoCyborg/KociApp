//
//  ImpostazioniView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct ImpostazioniView: View {
    
    // 🚀 La variabile collegata al telefono
        @AppStorage("impostazione_scadenze") private var avvisoScadenze = true
    
    // Brand Colors
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let terracotta = Color(red: 0.72, green: 0.49, blue: 0.44)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    let terracottaChiaro = Color(red: 0.73, green: 0.55, blue: 0.49)
    
    //@State private var notificheAttive = true
    
    // User Data
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Header Title
                Text("Settings")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(grigioScuroTesto)
                    .padding(.top, 15)
                    .padding(.horizontal, 24)
                
                // --- AVATAR SECTION (FIXED CENTERED) ---
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(terracottaChiaro)
                            .frame(width: 80, height: 80)
                        
                        if nomeUtente.isEmpty {
                            Image(systemName: "person.fill")
                                .font(.system(size: 38)) // Size adjusted for balance
                                .foregroundColor(.white)
                                // Rimosso il padding che decentrava l'icona
                        } else {
                            Text(String(nomeUtente.prefix(1)).uppercased())
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 10)
                    
                    Text(nomeUtente.isEmpty ? "New User" : nomeUtente)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(grigioScuroTesto)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
                
                // Settings Menu
                VStack(spacing: 12) {
                    
                    NavigationLink(destination: ProfiloView()) {
                        ImpostazioniRigaView(titolo: "My Profile")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(destination: PrivacyTerminiView()) {
                        ImpostazioniRigaView(titolo: "Privacy & Terms")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Notifications Toggle
                    HStack {
                        Text("Expiration Notifications")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(grigioScuroTesto)
                        Spacer()
                        Toggle("", isOn: $avvisoScadenze) // 🚀 Ora è collegato alla memoria del telefono! //$notificheAttive)
                            .labelsHidden()
                            .tint(verdeSalvia)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Logout Action
                HStack {
                    Spacer()
                    Button(action: {
                        print("Logging out...")
                    }) {
                        Text("Log Out")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(terracotta)
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// Support View for Menu Rows
struct ImpostazioniRigaView: View {
    var titolo: String
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let grigioFreccia = Color(red: 0.8, green: 0.8, blue: 0.8)
    
    var body: some View {
        HStack {
            Text(titolo)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(grigioScuroTesto)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(grigioFreccia)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    NavigationStack {
        ImpostazioniView()
    }
}
