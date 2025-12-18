//
//  DraggableClothingCell.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

protocol DraggableClothingCellDelegate: AnyObject {
    func cellDidBeginDragging(_ cell: DraggableClothingCell, with item: ClothingItem)
    func cellDidDrag(_ cell: DraggableClothingCell, with item: ClothingItem, to point: CGPoint)
    func cellDidEndDragging(_ cell: DraggableClothingCell, with item: ClothingItem, at point: CGPoint)
}

class DraggableClothingCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let instructionLabel = UILabel()
    weak var delegate: DraggableClothingCellDelegate?
    private var clothingItem: ClothingItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        
        nameLabel.font = .systemFont(ofSize: 11, weight: .medium)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        contentView.addSubview(nameLabel)
        
        instructionLabel.text = "Hold & Drag ↑"
        instructionLabel.font = .systemFont(ofSize: 9)
        instructionLabel.textColor = .systemGray
        instructionLabel.textAlignment = .center
        instructionLabel.alpha = 0.7
        contentView.addSubview(instructionLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.55),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            
            instructionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            instructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            instructionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        ])
    }
    
    private func setupGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.2 // Faster response
        addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let item = clothingItem else { return }
        
        switch gesture.state {
        case .began:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.contentView.layer.borderColor = UIColor.systemBlue.cgColor
                self.contentView.layer.borderWidth = 2
            }
            
            delegate?.cellDidBeginDragging(self, with: item)
            
        case .changed:
            let location = gesture.location(in: superview?.superview)
            delegate?.cellDidDrag(self, with: item, to: location)
            
        case .ended, .cancelled:
            let location = gesture.location(in: superview?.superview)
            delegate?.cellDidEndDragging(self, with: item, at: location)
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
                self.contentView.layer.borderColor = UIColor.systemGray4.cgColor
                self.contentView.layer.borderWidth = 1
            }
            
        default:
            break
        }
    }
    
    func configure(with item: ClothingItem) {
        clothingItem = item
        if let image = ImageManager.shared.loadImage(named: item.imageName) {
            imageView.image = image
        }
        nameLabel.text = item.name
        
        instructionLabel.isHidden = true
    }
    
    func showInstruction(_ show: Bool) {
        instructionLabel.isHidden = !show
    }
}
