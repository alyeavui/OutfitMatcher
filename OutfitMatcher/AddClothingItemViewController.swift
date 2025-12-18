//
//  AddClothingItemViewController.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

protocol AddClothingItemDelegate: AnyObject {
    func didAddClothingItem(_ item: ClothingItem)
}

class AddClothingItemViewController: UIViewController {
    
    var selectedImage: UIImage?
    weak var delegate: AddClothingItemDelegate?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView = UIImageView()
    private let nameTextField = UITextField()
    private let categoryPicker = UIPickerView()
    private let seasonPicker = UIPickerView()
    private let materialTextField = UITextField()
    private let sizeTextField = UITextField()
    private let colorTextField = UITextField()
    
    private var selectedCategory: ClothingCategory = .shirt
    private var selectedSeason: Season = .allSeasons
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        title = "Add Clothing Item"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        imageView.image = selectedImage
        imageView.contentMode = .scaleAspectFit
        
        nameTextField.placeholder = "Item name"
        nameTextField.borderStyle = .roundedRect
        
        materialTextField.placeholder = "Material"
        materialTextField.borderStyle = .roundedRect
        
        sizeTextField.placeholder = "Size"
        sizeTextField.borderStyle = .roundedRect
        
        colorTextField.placeholder = "Color"
        colorTextField.borderStyle = .roundedRect
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        seasonPicker.delegate = self
        seasonPicker.dataSource = self
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [
            createLabeledView(label: "Photo", view: imageView, height: 200),
            createLabeledView(label: "Name", view: nameTextField),
            createLabeledView(label: "Category", view: categoryPicker, height: 150),
            createLabeledView(label: "Season", view: seasonPicker, height: 150),
            createLabeledView(label: "Material", view: materialTextField),
            createLabeledView(label: "Size", view: sizeTextField),
            createLabeledView(label: "Color", view: colorTextField)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func createLabeledView(label: String, view: UIView, height: CGFloat? = nil) -> UIView {
        let container = UIView()
        let labelView = UILabel()
        labelView.text = label
        
        container.addSubview(labelView)
        container.addSubview(view)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            view.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 8),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        if let height = height {
            view.heightAnchor.constraint(equalToConstant: height).isActive = true
        } else {
            view.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        
        return container
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let image = selectedImage else {
            showAlert(message: "Please fill in all required fields")
            return
        }
        
        let imageName = UUID().uuidString
        guard let savedImageName = ImageManager.shared.saveImage(image, withName: imageName) else {
            showAlert(message: "Failed to save image")
            return
        }
        
        let item = ClothingItem(
            name: name,
            imageName: savedImageName,
            category: selectedCategory,
            season: selectedSeason,
            material: materialTextField.text ?? "",
            size: sizeTextField.text ?? "",
            color: colorTextField.text ?? ""
        )
        
        DataManager.shared.addClothingItem(item)
        delegate?.didAddClothingItem(item)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddClothingItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return ClothingCategory.allCases.count
        } else {
            return Season.allCases.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return ClothingCategory.allCases[row].rawValue
        } else {
            return Season.allCases[row].rawValue
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == categoryPicker {
            selectedCategory = ClothingCategory.allCases[row]
        } else {
            selectedSeason = Season.allCases[row]
        }
    }
}
