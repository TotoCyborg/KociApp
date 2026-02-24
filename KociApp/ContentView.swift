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
            // Main app with bottom navigation bar
            MainTabView()
        } else {
            // Initial 3 explanation slides
            OnboardingView(onboardingCompletato: $haVistoOnboarding)
        }
    }
}

// Bottom tab bar navigation
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
            
            // 2. Pantry (previously Dispensa)
            DispensaView()
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Pantry")
                }
            
            // 3. Shopping List (previously Lista)
            SpesaView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }
        }
        .tint(verdeSalvia) // Colors the active icon in sage green
    }
}

#Preview {
    ContentView()
}
