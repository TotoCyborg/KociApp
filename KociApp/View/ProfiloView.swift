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
                
                // Titolo tradotto: "My Profile"
                Text("My Profile")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(grigioScuroTesto)
                    .padding(.top, 20)
                
                // Form di inserimento
                VStack(spacing: 16) {
                    
                    // Sezione Nome tradotta: "First Name"
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("e.g. Marco", text: $nomeUtente)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .autocapitalization(.words)
                    }
                    
                    // Sezione Cognome tradotta: "Last Name"
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        TextField("e.g. Rossi", text: $cognomeUtente)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .autocapitalization(.words)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfiloView()
}
