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
                    
                    // Titolo tradotto: "Privacy & Terms"
                    Text("Privacy & Terms")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(grigioScuroTesto)
                        .padding(.top, 20)
                    
                    // Testo legale tradotto
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("1. Data Collection\nOur app is committed to protecting your privacy. We only collect the data necessary to manage your pantry and shopping list.\n\n2. Data Usage\nThe data entered is saved locally to ensure maximum security. We do not sell your data to third parties.\n\n3. Transparency\nWe reserve the right to modify these conditions at any time, notifying you in a timely manner.")
                            .font(.system(size: 16))
                            .foregroundColor(grigioScuroTesto)
                            .lineSpacing(4)
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
