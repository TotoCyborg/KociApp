//
//  ContentView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct ContentView: View {
    
    // colore verde
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Dashboard")
                }
            
            DispensaView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Dispensa")
                }
            
            SpesaView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lista")
                }
        }
        .preferredColorScheme(.light)
        .tint(verdeSalvia) // colore icona attiva
    }
}

#Preview {
    ContentView()
}
