import UIKit

class AIViewController: UIViewController {
    
    @IBOutlet weak var hatsCollectionView: UICollectionView!
    @IBOutlet weak var shirtsCollectionView: UICollectionView!
    @IBOutlet weak var pantsCollectionView: UICollectionView!
    @IBOutlet weak var shoesCollectionView: UICollectionView!
    @IBOutlet weak var matchButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var hats: [ClothingItem] = []
    private var shirts: [ClothingItem] = []
    private var pants: [ClothingItem] = []
    private var shoes: [ClothingItem] = []
    
    private var selectedHat: ClothingItem?
    private var selectedShirt: ClothingItem?
    private var selectedPants: ClothingItem?
    private var selectedShoes: ClothingItem?
    
    private var isMatching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupUI() {
        saveButton?.isEnabled = false
        saveButton?.setTitle("Save", for: .normal)
        saveButton?.setTitleColor(.white, for: .normal)
        saveButton?.layer.cornerRadius = 8
        
        activityIndicator?.hidesWhenStopped = true
    }
    
    private func setupCollectionViews() {
        [hatsCollectionView, shirtsCollectionView, pantsCollectionView, shoesCollectionView].forEach { cv in
            cv?.delegate = self
            cv?.dataSource = self
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.minimumLineSpacing = 10
            cv?.collectionViewLayout = layout
        }
    }
    
    private func loadData() {
        let allItems = DataManager.shared.loadClothingItems()
        hats = allItems.filter { $0.category == .hat }
        shirts = allItems.filter { $0.category == .shirt }
        pants = allItems.filter { $0.category == .pants }
        shoes = allItems.filter { $0.category == .shoes }
        
        [hatsCollectionView, shirtsCollectionView, pantsCollectionView, shoesCollectionView].forEach { $0?.reloadData() }
    }
    
    @IBAction func matchTapped(_ sender: UIButton) {
        guard !isMatching else { return }
        
        if shirts.isEmpty || pants.isEmpty {
            showAlert(title: "Add Clothes", message: "Please add items to your closet first.")
            return
        }
        
        isMatching = true
        matchButton.isEnabled = false
        activityIndicator.startAnimating()
        
        let data = ["hats": hats.map { ["id": $0.id.uuidString, "color": $0.color] },
                    "shirts": shirts.map { ["id": $0.id.uuidString, "color": $0.color] },
                    "pants": pants.map { ["id": $0.id.uuidString, "color": $0.color] },
                    "shoes": shoes.map { ["id": $0.id.uuidString, "color": $0.color] }]
        
        AIService.shared.getOutfitRecommendation(clothingItems: data) { [weak self] result in
            DispatchQueue.main.async {
                self?.isMatching = false
                self?.matchButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let rec):
                    self?.applyRecommendation(rec)
                case .failure(let err):
                    self?.showError(err)
                }
            }
        }
    }
    
    private func applyRecommendation(_ rec: OutfitRecommendation) {
        if let id = rec.shirtID, let item = shirts.first(where: { $0.id.uuidString == id }) {
            selectedShirt = item
            animateCarouselToItem(collectionView: shirtsCollectionView, item: item, in: shirts)
        }
        if let id = rec.pantsID, let item = pants.first(where: { $0.id.uuidString == id }) {
            selectedPants = item
            animateCarouselToItem(collectionView: pantsCollectionView, item: item, in: pants)
        }
        if let id = rec.shoesID, let item = shoes.first(where: { $0.id.uuidString == id }) {
            selectedShoes = item
            animateCarouselToItem(collectionView: shoesCollectionView, item: item, in: shoes)
        }
        
        saveButton.isEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showAlert(title: "Style Selected!", message: rec.explanation)
        }
    }
    
    private func animateCarouselToItem(collectionView: UICollectionView?, item: ClothingItem, in items: [ClothingItem]) {
        guard let cv = collectionView, let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        cv.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func showError(_ error: AIServiceError) {
        showAlert(title: "Connection Error", message: error.localizedDescription)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AIViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hatsCollectionView { return hats.count }
        if collectionView == shirtsCollectionView { return shirts.count }
        if collectionView == pantsCollectionView { return pants.count }
        return shoes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothingItemCell", for: indexPath) as! ClothingItemCell
        let item: ClothingItem
        if collectionView == hatsCollectionView { item = hats[indexPath.item] }
        else if collectionView == shirtsCollectionView { item = shirts[indexPath.item] }
        else if collectionView == pantsCollectionView { item = pants[indexPath.item] }
        else { item = shoes[indexPath.item] }
        cell.configure(with: item)
        return cell
    }
}
