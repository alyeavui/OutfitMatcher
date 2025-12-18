//
//  CreateViewController.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class CreateViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    private var clothingItems: [ClothingItem] = []
    private var selectedClothingView: DraggableClothingView?
    private var clothingViews: [DraggableClothingView] = []
    private var bottomSheetVC: ClothesBottomSheetViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCanvas()
        loadUserPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupCanvas() {
        canvasView.backgroundColor = .clear
        canvasView.isUserInteractionEnabled = true
        view.bringSubviewToFront(canvasView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(canvasTapped))
        canvasView.addGestureRecognizer(tapGesture)
    }
    
    private func loadUserPhoto() {
        if let userPhoto = DataManager.shared.loadUserPhoto() {
            backgroundImageView.image = userPhoto
            backgroundImageView.contentMode = .scaleAspectFit
        }
    }
    
    private func loadData() {
        clothingItems = DataManager.shared.loadClothingItems()
    }

    @IBAction func addItemTapped(_ sender: UIButton) {
        showClothesBottomSheet()
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard !clothingViews.isEmpty else {
            showAlert(message: "Add some clothes first!")
            return
        }
        
        let alert = UIAlertController(title: "Save Outfit", message: "Enter outfit name", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Outfit name" }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else {
                self.showAlert(message: "Please enter a name")
                return
            }
            self.saveOutfit(name: name)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func layerButtonTapped(_ sender: UIButton) {
        guard let selectedView = selectedClothingView else {
            print("No clothing item selected!")
            return
        }

        guard let currentIndex = clothingViews.firstIndex(where: { $0 == selectedView }) else { return }
        
        switch sender.tag {
        case 0:
            if currentIndex > 0 {
                clothingViews.remove(at: currentIndex)
                clothingViews.insert(selectedView, at: 0)
                canvasView.sendSubviewToBack(selectedView)
            }
            
        case 1:
            if currentIndex < clothingViews.count - 1 {
                clothingViews.remove(at: currentIndex)
                clothingViews.append(selectedView)
                canvasView.bringSubviewToFront(selectedView)
            }
        default:
            break
        }
        flashSelection(selectedView)
    }

    private func showClothesBottomSheet() {
        let bottomSheet = ClothesBottomSheetViewController()
        bottomSheet.clothingItems = clothingItems
        bottomSheet.delegate = self
        bottomSheet.modalPresentationStyle = .overCurrentContext
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        bottomSheetVC = bottomSheet
        present(bottomSheet, animated: false) {
            bottomSheet.animatePresentation()
        }
    }
    
    private func addClothingToCanvas(item: ClothingItem, at point: CGPoint) {
        guard let image = ImageManager.shared.loadImage(named: item.imageName) else { return }
        
        let canvasPoint = canvasView.convert(point, from: view)
        
        let clothingView = DraggableClothingView(frame: CGRect(x: canvasPoint.x - 75,
                                                               y: canvasPoint.y - 75,
                                                               width: 150,
                                                               height: 150))
        clothingView.imageView.image = image
        clothingView.clothingItem = item
        clothingView.delegate = self
        
        canvasView.addSubview(clothingView)
        clothingViews.append(clothingView)
        
        selectClothingView(clothingView)
        
        print("Added clothing at: \(canvasPoint), total items: \(clothingViews.count)")
    }
    
    private func selectClothingView(_ view: DraggableClothingView) {
        clothingViews.forEach { $0.isSelected = false }
        selectedClothingView = view
        view.isSelected = true
        
        print("Selected clothing item")
    }
    
    @objc private func canvasTapped() {
        clothingViews.forEach { $0.isSelected = false }
        selectedClothingView = nil
        print("Deselected all items")
    }
    
    private func flashSelection(_ view: DraggableClothingView) {
        UIView.animate(withDuration: 0.15, animations: {
            view.layer.borderWidth = 4
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                view.layer.borderWidth = 2
            }
        }
    }
    
    private func saveOutfit(name: String) {
        clothingViews.forEach { $0.isSelected = false }
        
        guard let outfitImage = ImageManager.shared.captureView(canvasView) else {
            showAlert(message: "Failed to save outfit")
            return
        }
        
        let imageName = UUID().uuidString
        guard let savedImageName = ImageManager.shared.saveImage(outfitImage, withName: imageName) else {
            showAlert(message: "Failed to save image")
            return
        }
        
        let itemIDs = clothingViews.compactMap { $0.clothingItem?.id }
        let outfit = Outfit(name: name, imageName: savedImageName, itemIDs: itemIDs)
        DataManager.shared.addOutfit(outfit)
        
        showAlert(message: "Outfit saved!") {
            self.clearAllClothes()
        }
    }
    
    private func clearAllClothes() {
        clothingViews.forEach { $0.removeFromSuperview() }
        clothingViews.removeAll()
        selectedClothingView = nil
    }
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
}

extension CreateViewController: ClothesBottomSheetDelegate {
    func didDragClothingItem(_ item: ClothingItem, to point: CGPoint) {
        addClothingToCanvas(item: item, at: point)
    }
    
    func didTapAddNewItem() {
        bottomSheetVC?.animateDismissal()
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
extension CreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else { return }
        showAddClothingItemForm(with: image)
    }
}

extension CreateViewController: AddClothingItemDelegate {
    func didAddClothingItem(_ item: ClothingItem) {
        loadData()
    }
}

extension CreateViewController: DraggableClothingViewDelegate {
    func clothingViewDidSelect(_ view: DraggableClothingView) {
        selectClothingView(view)
    }
    
    func clothingViewDidDelete(_ view: DraggableClothingView) {
        view.removeFromSuperview()
        clothingViews.removeAll { $0 == view }
        if selectedClothingView == view {
            selectedClothingView = nil
        }
        print("Deleted clothing item, remaining: \(clothingViews.count)")
    }
}
