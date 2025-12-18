//
//  ImageManager.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class ImageManager {
    static let shared = ImageManager()
    
    private init() {}
    
    func saveImage(_ image: UIImage, withName name: String) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = "\(name).png"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    func loadImage(named name: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteImage(named name: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(name)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func captureView(_ view: UIView) -> UIImage? {
        let displayScale = view.traitCollection.displayScale
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, displayScale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
