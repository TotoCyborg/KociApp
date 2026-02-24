//
//  ContentView.swift
//  KociApp_Grafica
//
//  Created by elio koci on 20/02/26.
//

import SwiftUI

struct ContentView: View {
    // @AppStorage ricorda sul telefono se l'utente ha già completato l'onboarding
    @AppStorage("haVistoOnboarding") var haVistoOnboarding = false
    
    var body: some View {
        if haVistoOnboarding {
            // se lo ha già visto, carica la tua app normale con la barra in basso
            MainTabView()
        } else {
            // altrimenti, mostra le 3 slide di spiegazione iniziale
            OnboardingView(onboardingCompletato: $haVistoOnboarding)
        }
    }
}

// contiene le 3 pagine principali
struct MainTabView: View {
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    var body: some View {
        TabView {
            // 1. Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Dashboard")
                }
            
            // 2. Dispensa
            DispensaView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Dispensa")
                }
            
            // 3. Lista della Spesa
            SpesaView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lista")
                }
        }
        .tint(verdeSalvia) // Colora di verde l'icona cliccata
    }
}

#Preview {
    ContentView()
}
