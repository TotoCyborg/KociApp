//
//  NotificationManager.swift
//  KociApp
//
//  Created by GIORGIO GALIOTO on 25/02/26.
//

import Foundation
import UserNotifications
import SwiftUI // Serve per AppStorage

class NotificationManager {
    // Rende il manager accessibile da qualsiasi parte dell'app
    static let shared = NotificationManager()
    
    @AppStorage("impostazione_scadenze") private var avvisoScadenze = true
    
    // 1. CHIEDE IL PERMESSO ALL'UTENTE
    func richiediPermesso() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Permesso notifiche accordato!")
            } else {
                print("🚫 Permesso negato dall'utente.")
            }
        }
    }
    
    // 2. PROGRAMMA LA NOTIFICA
        func programmaNotifica(per prodotto: ScannedItem) {
            guard avvisoScadenze else {
                print("Notifica bloccata dallo switch 🚫")
                return
            }
            
            guard let dataScadenza = prodotto.expiryDate,
                  let nomeProdotto = prodotto.product?.productName else { return }
            
            // Creiamo la notifica
            let content = UNMutableNotificationContent()
            content.title = "KociApp: Alimento in Scadenza!"
            content.body = "Ehi! L'alimento \(nomeProdotto) scade domani."
            content.sound = .default
            
            // Calcoliamo la data: 1 GIORNO PRIMA della scadenza
            guard let dataNotifica = Calendar.current.date(byAdding: .day, value: -1, to: dataScadenza) else { return }
            
            // Impostiamo l'orario alle 18:00
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dataNotifica)
            dateComponents.hour = 18
            dateComponents.minute = 0
            
            // Usiamo il trigger per la data esatta
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // L'identifier unico fa in modo di non creare doppioni per lo stesso prodotto
            let request = UNNotificationRequest(identifier: prodotto.id.uuidString, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Errore notifica: \(error)")
                } else {
                    print("🔔 Notifica programmata per: \(nomeProdotto) alle ore 18:00 del giorno prima")
                }
            }
        }
    
    // 3. CANCELLA LA NOTIFICA (Se l'utente elimina il cibo dalla dispensa)
    func cancellaNotifica(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
