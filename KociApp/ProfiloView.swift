//
//  SwiftUIView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct ProfiloView: View {
    // appstorage per il nome e cognome
    @AppStorage("nomeSalvato") private var nomeUtente: String = ""
    @AppStorage("cognomeSalvato") private var cognomeUtente: String = ""
    
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Il mio profilo")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(grigioScuroTesto)
                    .padding(.top, 20)
                
                // testo
                VStack(spacing: 16) {
                    
                    // nome
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nome")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("Es. Marco", text: $nomeUtente)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            // maiuscola automatica
                            .autocapitalization(.words)
                    }
                    
                    // cognome
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cognome")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("Es. Rossi", text: $cognomeUtente)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .autocapitalization(.words)
                    }
                }
                
                Spacer() // in alto
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfiloView()
}
