//
//  DraggableClothingView.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

protocol DraggableClothingViewDelegate: AnyObject {
    func clothingViewDidSelect(_ view: DraggableClothingView)
    func clothingViewDidDelete(_ view: DraggableClothingView)
}

class DraggableClothingView: UIView {
    let imageView = UIImageView()
    weak var delegate: DraggableClothingViewDelegate?
    var clothingItem: ClothingItem?
    
    var isSelected: Bool = false {
        didSet {
            updateSelectionUI()
        }
    }
    
    private var initialScale: CGFloat = 1.0
    private var initialRotation: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.borderWidth = 0
        
        isUserInteractionEnabled = true
        
        setupGestures()
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation))
        rotationGesture.delegate = self
        addGestureRecognizer(rotationGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isSelected else { return }
        
        let translation = gesture.translation(in: superview)
        
        switch gesture.state {
        case .changed:
            center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
            gesture.setTranslation(.zero, in: superview)
            
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard isSelected else { return }
        
        switch gesture.state {
        case .began:
            initialScale = 1.0
            
        case .changed:
            let scale = gesture.scale
            transform = transform.scaledBy(x: scale, y: scale)
            gesture.scale = 1.0
            
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard isSelected else { return }
        
        switch gesture.state {
        case .began:
            initialRotation = 0
            
        case .changed:
            let rotation = gesture.rotation
            transform = transform.rotated(by: rotation)
            gesture.rotation = 0
            
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.clothingViewDidSelect(self)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            let alert = UIAlertController(title: "Delete Item?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.delegate?.clothingViewDidDelete(self)
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(alert, animated: true)
            }
        }
    }

    private func updateSelectionUI() {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderWidth = self.isSelected ? 2 : 0
        }
    }
}

extension DraggableClothingView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer) ||
           (gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer) {
            return true
        }
        return false
    }
}
