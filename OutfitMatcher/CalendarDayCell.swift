//
//  CalendarDayCell.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    
    private let dayLabel = UILabel()
    private let outfitImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        dayLabel.textAlignment = .center
        outfitImageView.contentMode = .scaleAspectFit
        outfitImageView.clipsToBounds = true
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(outfitImageView)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        outfitImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            outfitImageView.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            outfitImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            outfitImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            outfitImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(day: Int, outfit: Outfit?, isToday: Bool) {
        dayLabel.text = "\(day)"
        
        if let outfit = outfit, let image = ImageManager.shared.loadImage(named: outfit.imageName) {
            outfitImageView.image = image
            outfitImageView.isHidden = false
        } else {
            outfitImageView.isHidden = true
        }
    }
}
