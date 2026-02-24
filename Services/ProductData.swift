//
//  OpenFoodFacts.swift
//  Kilo
//
//  Created by Salvatore Rita La Piana on 11/02/26.
//

import Foundation



//La risposta generale del server
struct ProductResponse: Codable {
    let code: String?
    let product: Product?
}

//Il Prodotto vero e proprio
struct Product: Codable, Hashable {
    let productName: String?
    let brands: String?
    let imageUrl: String?
    
    // CodingKeys serve a tradurre i nomi strani del server (snake_case)
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageUrl = "image_url"
    }
}

// L'Oggetto per la tua Lista
struct ScannedItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()         // Serve al ForEach per non confondersi
    let barcode: String
    var product: Product?   // I dati scaricati (inizialmente è nil/vuoto)
    var isLoading: Bool     // load wheel
    
    // New fields
    var expiryDate: Date?       // Può essere vuota all'inizio
    var status: FoodStatus = .inPantry // Di default è "In dispensa"
    var quantity: Int = 1       // Magari ne hai comprati 2 pacchi?
    }


//etichette possibili
enum FoodStatus: String, Codable {
    case inPantry = "In Dispensa" // Appena scansionato
    case consumed = "Consumato"   // Mangiato (Buono!)
    case thrown = "Buttato"       // Scaduto/Buttato (Cattivo...)
}




class FoodAPI {
    
    // Funzione asincrona che va su internet
    static func getProduct(barcode: String) async throws -> Product? {
        
        //Costruiamo l'indirizzo internet specifico per quel codice
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        
        // Controllo di sicurezza sull'URL
        guard let url = URL(string: urlString) else { return nil }
        
        //Chiamata di rete (URLSession)
        let (data, _) = try await URLSession.shared.data(from: url)
        
        //Decodifica
        let decoder = JSONDecoder()
        let result = try decoder.decode(ProductResponse.self, from: data)
        
        return result.product
    }
}
