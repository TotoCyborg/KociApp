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
        // Raggruppiamo la logica di navigazione per applicare il tema chiaro a TUTTA l'app
        Group {
            if haVistoOnboarding {
                // Main app with bottom navigation bar
                MainTabView()
            } else {
                // Initial 3 explanation slides
                OnboardingView(onboardingCompletato: $haVistoOnboarding)
            }
        }
        // LA MAGIA: Forza l'app a rimanere sempre e solo in Modalità Chiara
        .preferredColorScheme(.light)
    }
}

// Bottom tab bar navigation
struct MainTabView: View {
    let verdeSalvia = Color(red: 0.48, green: 0.59, blue: 0.49)
    
    // Inizializzatore per forzare l'aspetto della TabBar (sempre bianca e opaca)
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white // Forza il bianco
        
        // Applica l'aspetto fisso sia quando sei fermo, sia quando scorri una lista
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // 1. Dashboard
            DashboardView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Dashboard")
                }
            
            // 2. Pantry (previously Dispensa)
            DispensaView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Pantry")
                }
            
            // 3. Shopping List (previously Lista)
            TrendsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Trends")
                }
        }
        .tint(verdeSalvia) // Colors the active icon in sage green
    }
}

#Preview {
    ContentView()
}
