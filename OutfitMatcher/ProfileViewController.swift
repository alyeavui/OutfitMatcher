//
//  ProfileViewController.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var outfits: [Outfit] = []
    private var clothingItems: [ClothingItem] = []
    private var filteredItems: [ClothingItem] = []
    
    private var showFavoritesOnly = false
    private var selectedCategory: ClothingCategory?
    private var selectedSeason: Season?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(OutfitCell.self, forCellWithReuseIdentifier: "OutfitCell")
        collectionView.register(ClothingItemCell.self, forCellWithReuseIdentifier: "ClothingItemCell")
        
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.width - 40) / 2
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.3)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }
    
    private func loadData() {
        outfits = DataManager.shared.loadOutfits()
        clothingItems = DataManager.shared.loadClothingItems()
        applyFilters()
        collectionView.reloadData()
    }
    
    private func applyFilters() {
        filteredItems = clothingItems
        
        if let category = selectedCategory {
            filteredItems = filteredItems.filter { $0.category == category }
        }
        
        if let season = selectedSeason {
            filteredItems = filteredItems.filter { $0.season == season || $0.season == .allSeasons }
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        collectionView.reloadData()
    }
    
    @IBAction func filterTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Filter Items", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "All Categories", style: .default) { _ in
            self.selectedCategory = nil
            self.applyFilters()
            self.collectionView.reloadData()
        })
        
        for category in ClothingCategory.allCases {
            alert.addAction(UIAlertAction(title: category.rawValue, style: .default) { _ in
                self.selectedCategory = category
                self.applyFilters()
                self.collectionView.reloadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Add Clothing Item", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentImagePicker(sourceType: .camera)
        })
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func showAddClothingItemForm(with image: UIImage) {
        let vc = AddClothingItemViewController()
        vc.selectedImage = image
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return showFavoritesOnly ? outfits.filter { $0.isFavorite }.count : outfits.count
        } else {
            return filteredItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OutfitCell", for: indexPath) as! OutfitCell
            let filtered = showFavoritesOnly ? outfits.filter { $0.isFavorite } : outfits
            let outfit = filtered[indexPath.item]
            cell.configure(with: outfit)
            
            cell.favoriteButtonTapped = { [weak self] in
                DataManager.shared.toggleFavorite(outfitID: outfit.id)
                self?.loadData()
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingItemCell", for: indexPath) as! ClothingItemCell
            cell.configure(with: filteredItems[indexPath.item])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let filtered = showFavoritesOnly ? outfits.filter { $0.isFavorite } : outfits
            let outfit = filtered[indexPath.item]
            
            let alert = UIAlertController(title: outfit.name, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                DataManager.shared.deleteOutfit(id: outfit.id)
                ImageManager.shared.deleteImage(named: outfit.imageName)
                self.loadData()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        showAddClothingItemForm(with: image)
    }
}

extension ProfileViewController: AddClothingItemDelegate {
    func didAddClothingItem(_ item: ClothingItem) {
        loadData()
    }
}
