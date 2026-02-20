//
//  PrivacyTerminiView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct PrivacyTerminiView: View {
    let colorPanna = Color(red: 0.96, green: 0.95, blue: 0.92)
    let grigioScuroTesto = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    var body: some View {
        ZStack {
            colorPanna.ignoresSafeArea()
            
            // scroll view testo
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Privacy & Termini")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(grigioScuroTesto)
                        .padding(.top, 20)
                    
                    //testo legale esempio
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("1. Raccolta dei dati\nLa nostra app si impegna a proteggere la tua privacy. Raccogliamo solo i dati necessari per gestire la tua dispensa e la lista della spesa.\n\n2. Utilizzo dei dati\nI dati inseriti vengono salvati localmente per garantirti la massima sicurezza. Non vendiamo i tuoi dati a terzi.\n\n3. Trasparenza\nCi riserviamo il diritto di modificare queste condizioni in qualsiasi momento, avvisandoti in modo tempestivo.")
                            .font(.system(size: 16))
                            .foregroundColor(grigioScuroTesto)
                            .lineSpacing(4) // spazio
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacyTerminiView()
}
