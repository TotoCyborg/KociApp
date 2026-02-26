//
//  DataManager.swift
//  Kilo
//
//  Created by Salvatore Rita La Piana on 17/02/26.
//

import Foundation

class DataManager {
    
    private static let fileName = "saved_food.json"//file to storage data
    
    //creation of address in the iphone
    private static var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
    
    // MARK: - saveItems
    static func saveItems(_ items: [ScannedItem]) {
        //if file corrupt or there's not space, gestisci errore
        do{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted//formatting to render nice text
            
            let data = try encoder.encode(items)//trasforma l'array in un oggetto data (byte)
            try data.write(to: fileURL, options: [.atomic])//scrive su disco, ma utilizzando atomic prima scrive tutto su un file temporaneo e poi lo scambia. figata pk se crasha mentre scrive non ti trovi un file scritto a meta e non si corrompe
            print("✅ Dati salvati con successo in: \(fileURL)")
        } catch {//gestione errore
            print("❌ Errore durante la salvataggio dei dati: \(error)")
        }
    }
    
    // MARK: - loadItems
    static func loadItems() -> [ScannedItem] {
        do {
            if !FileManager.default.fileExists(atPath: fileURL.path){// se il file non esiste, hai appena installato l'applicazione
                return [] //restituisce subito  array vuoto se no crasha pure il paradiso
            }
            
            let data = try Data(contentsOf: fileURL)// legge dal disco e inserisce in data
            let decoder = JSONDecoder()//traduce al contrario
            let items = try decoder.decode([ScannedItem].self, from: data)//aspettati ScannedItem, se ricevi altro errati
            print("✅ Caricati \(items.count) prodotti.")
            return items//lista pronta
        }catch {
            print("❌ Errore durante la caricamento dei dati: \(error)")
            return []
        }
    }
    
    // MARK: - MOTORE TRENDS
        
        // Generatore di file
        static func getURL(for filename: String) -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        }

        // --- FILE: CIBI SALVATI ---
        static func loadSalvati() -> [ScannedItem] {
            guard let data = try? Data(contentsOf: getURL(for: "salvati.json")),
                  let items = try? JSONDecoder().decode([ScannedItem].self, from: data) else { return [] }
            return items
        }

        static func saveSalvati(_ items: [ScannedItem]) {
            if let data = try? JSONEncoder().encode(items) {
                try? data.write(to: getURL(for: "salvati.json"))
            }
        }

        // --- FILE: CIBI SCADUTI (SPRECATI) ---
        static func loadScaduti() -> [ScannedItem] {
            guard let data = try? Data(contentsOf: getURL(for: "scaduti.json")),
                  let items = try? JSONDecoder().decode([ScannedItem].self, from: data) else { return [] }
            return items
        }

        static func saveScaduti(_ items: [ScannedItem]) {
            if let data = try? JSONEncoder().encode(items) {
                try? data.write(to: getURL(for: "scaduti.json"))
            }
        }
}




