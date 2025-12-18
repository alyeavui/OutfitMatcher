//
//  ClothesBottomSheetViewController.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

protocol ClothesBottomSheetDelegate: AnyObject {
    func didDragClothingItem(_ item: ClothingItem, to point: CGPoint)
    func didTapAddNewItem()
}

class ClothesBottomSheetViewController: UIViewController {
 
    var clothingItems: [ClothingItem] = []
    weak var delegate: ClothesBottomSheetDelegate?
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let addNewButton = UIButton(type: .system)
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let dimmedView = UIView()
    private var containerBottomConstraint: NSLayoutConstraint!
    private var draggingImageView: UIImageView?
    private var isDragging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimmedView.alpha = 0
        view.addSubview(dimmedView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowOffset = CGSize(width: 0, height: -2)
        containerView.layer.shadowRadius = 10
        view.addSubview(containerView)
        titleLabel.text = "Your clothes"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        containerView.addSubview(titleLabel)
        addNewButton.setTitle("Add new +", for: .normal)
        addNewButton.setTitleColor(.systemBlue, for: .normal)
        addNewButton.addTarget(self, action: #selector(addNewTapped), for: .touchUpInside)
        containerView.addSubview(addNewButton)
        containerView.addSubview(collectionView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addNewButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerHeight: CGFloat = view.frame.height / 2
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: containerHeight)
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: containerHeight),
            containerBottomConstraint,
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            addNewButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addNewButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DraggableClothingCell.self, forCellWithReuseIdentifier: "DraggableClothingCell")
    }

    func animatePresentation() {
        containerBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func animateDismissal(completion: (() -> Void)? = nil) {
        containerBottomConstraint.constant = view.frame.height / 2
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }

    @objc private func dimmedViewTapped() {
        if !isDragging {
            animateDismissal()
        }
    }
    
    @objc private func addNewTapped() {
        delegate?.didTapAddNewItem()
    }

    private func showDraggingPreview(with image: UIImage, at point: CGPoint) {
        if draggingImageView == nil {
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            imageView.contentMode = .scaleAspectFit
            imageView.alpha = 0.7
            imageView.layer.shadowColor = UIColor.black.cgColor
            imageView.layer.shadowOpacity = 0.5
            imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
            imageView.layer.shadowRadius = 8
            view.addSubview(imageView)
            draggingImageView = imageView
        }
        
        draggingImageView?.center = point
    }
    
    private func updateDraggingPreview(to point: CGPoint) {
        draggingImageView?.center = point
        let threshold = containerView.frame.minY
        if point.y < threshold {
            draggingImageView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            draggingImageView?.alpha = 0.9
        } else {
            draggingImageView?.transform = .identity
            draggingImageView?.alpha = 0.7
        }
    }
    
    private func removeDraggingPreview() {
        UIView.animate(withDuration: 0.2) {
            self.draggingImageView?.alpha = 0
            self.draggingImageView?.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        } completion: { _ in
            self.draggingImageView?.removeFromSuperview()
            self.draggingImageView = nil
        }
    }
}

extension ClothesBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DraggableClothingCell", for: indexPath) as! DraggableClothingCell
        cell.configure(with: clothingItems[indexPath.item])
        cell.delegate = self
        return cell
    }
}

extension ClothesBottomSheetViewController: DraggableClothingCellDelegate {
    func cellDidBeginDragging(_ cell: DraggableClothingCell, with item: ClothingItem) {
        isDragging = true
        
        if let image = ImageManager.shared.loadImage(named: item.imageName) {
            let cellCenter = view.convert(cell.center, from: collectionView)
            showDraggingPreview(with: image, at: cellCenter)
        }
    }
    
    func cellDidDrag(_ cell: DraggableClothingCell, with item: ClothingItem, to point: CGPoint) {
        let viewPoint = view.convert(point, from: collectionView)
        updateDraggingPreview(to: viewPoint)
    }
    
    func cellDidEndDragging(_ cell: DraggableClothingCell, with item: ClothingItem, at point: CGPoint) {
        isDragging = false
        
        let screenPoint = view.convert(point, from: collectionView)
    
        if screenPoint.y < containerView.frame.minY {
            delegate?.didDragClothingItem(item, to: screenPoint)
            removeDraggingPreview()
            animateDismissal()
        } else {
            removeDraggingPreview()
        }
    }
}
