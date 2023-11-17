//
//  MTGCard.swift
//  MTG_App
//
//  Created by MacBook Pro on 10/11/23.
//

//import Foundation
//
//struct MTGCard: Codable, Identifiable {
//    var id: UUID
//    var name: String
//    var type_line: String
//    var oracle_text: String
//    var image_uris: ImageURIs?
//
//    // Define other properties as needed based on your JSON structure
//
//    struct ImageURIs: Codable {
//        var small: String?
//        var normal: String?
//        var large: String?
//        // Add other image URL properties if needed
//    }
//}
//
//struct MTGCardList: Codable {
//    var object: String
//    var total_cards: Int
//    var has_more: Bool
//    var data: [MTGCard]
//}
//

import Foundation
import SwiftUI

struct MTGCard: Codable, Identifiable{
    var id: UUID
    var name: String
    var type_line: String
    var oracle_text: String
    var image_uris: ImageURIs?
    var collector_number: String?
    var legalities: [String: String]?
  
//        var legalities: String?;
//    Add legalities property

    // Define other properties as needed based on your JSON structure

    struct ImageURIs: Codable {
        var small: String?
        var normal: String?
        var large: String?
        var art_crop: String?
        // Add other image URL properties if needed
    }

}



struct MTGCardList: Codable {
    var object: String
    var total_cards: Int
    var has_more: Bool
    var data: [MTGCard]
}
