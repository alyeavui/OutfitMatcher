//
//  DataManager.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class DataManager {
    static let shared = DataManager()
    
    private let clothingItemsKey = "clothingItems"
    private let outfitsKey = "outfits"
    private let calendarEntriesKey = "calendarEntries"
    private let userPhotoKey = "userPhoto"
    
    private init() {}
    func saveClothingItems(_ items: [ClothingItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: clothingItemsKey)
        }
    }
    
    func loadClothingItems() -> [ClothingItem] {
        guard let data = UserDefaults.standard.data(forKey: clothingItemsKey),
              let items = try? JSONDecoder().decode([ClothingItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func addClothingItem(_ item: ClothingItem) {
        var items = loadClothingItems()
        items.append(item)
        saveClothingItems(items)
    }
    
    func deleteClothingItem(id: UUID) {
        var items = loadClothingItems()
        items.removeAll { $0.id == id }
        saveClothingItems(items)
    }
    
    func getClothingItem(by id: UUID) -> ClothingItem? {
        return loadClothingItems().first { $0.id == id }
    }

    func saveOutfits(_ outfits: [Outfit]) {
        if let encoded = try? JSONEncoder().encode(outfits) {
            UserDefaults.standard.set(encoded, forKey: outfitsKey)
        }
    }
    
    func loadOutfits() -> [Outfit] {
        guard let data = UserDefaults.standard.data(forKey: outfitsKey),
              let outfits = try? JSONDecoder().decode([Outfit].self, from: data) else {
            return []
        }
        return outfits
    }
    
    func addOutfit(_ outfit: Outfit) {
        var outfits = loadOutfits()
        outfits.append(outfit)
        saveOutfits(outfits)
    }
    
    func deleteOutfit(id: UUID) {
        var outfits = loadOutfits()
        outfits.removeAll { $0.id == id }
        saveOutfits(outfits)
    }
    
    func toggleFavorite(outfitID: UUID) {
        var outfits = loadOutfits()
        if let index = outfits.firstIndex(where: { $0.id == outfitID }) {
            outfits[index].isFavorite.toggle()
            saveOutfits(outfits)
        }
    }

    func saveCalendarEntries(_ entries: [CalendarEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: calendarEntriesKey)
        }
    }
    
    func loadCalendarEntries() -> [CalendarEntry] {
        guard let data = UserDefaults.standard.data(forKey: calendarEntriesKey),
              let entries = try? JSONDecoder().decode([CalendarEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func addCalendarEntry(_ entry: CalendarEntry) {
        var entries = loadCalendarEntries()
        entries.removeAll { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }
        entries.append(entry)
        saveCalendarEntries(entries)
    }
    
    func getEntry(for date: Date) -> CalendarEntry? {
        return loadCalendarEntries().first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func saveUserPhoto(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: userPhotoKey)
        }
    }
    
    func loadUserPhoto() -> UIImage? {
        guard let data = UserDefaults.standard.data(forKey: userPhotoKey) else {
            return nil
        }
        return UIImage(data: data)
    }
}
