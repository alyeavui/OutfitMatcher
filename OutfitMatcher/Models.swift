//
//  Models.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

enum ClothingCategory: String, Codable, CaseIterable {
    case hat = "Hat"
    case shirt = "Shirt"
    case pants = "Pants"
    case shoes = "Shoes"
    case dress = "Dress"
    case accessory = "Accessory"
}

enum Season: String, Codable, CaseIterable {
    case spring = "Spring"
    case summer = "Summer"
    case fall = "Fall"
    case winter = "Winter"
    case allSeasons = "All Seasons"
}

struct ClothingItem: Codable {
    let id: UUID
    var name: String
    var imageName: String
    var category: ClothingCategory
    var season: Season
    var material: String
    var size: String
    var color: String
    
    init(name: String, imageName: String, category: ClothingCategory, season: Season, material: String, size: String, color: String) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.category = category
        self.season = season
        self.material = material
        self.size = size
        self.color = color
    }
}

struct Outfit: Codable {
    let id: UUID
    var name: String
    var imageName: String
    var itemIDs: [UUID]
    var dateCreated: Date
    var isFavorite: Bool
    
    init(name: String, imageName: String, itemIDs: [UUID]) {
        self.id = UUID()
        self.name = name
        self.imageName = imageName
        self.itemIDs = itemIDs
        self.dateCreated = Date()
        self.isFavorite = false
    }
}

struct CalendarEntry: Codable {
    let id: UUID
    var date: Date
    var outfitID: UUID
    
    init(date: Date, outfitID: UUID) {
        self.id = UUID()
        self.date = date
        self.outfitID = outfitID
    }
}
