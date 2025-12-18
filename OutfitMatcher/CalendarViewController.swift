//
//  CalendarViewController.swift
//  OutfitMatcher
//
//  Created by Ayaulym on 18.12.2025.
//

import UIKit

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var currentDate = Date()
    private var calendarEntries: [CalendarEntry] = []
    private var daysInMonth: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        updateCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (view.bounds.width - 60) / 7
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.2)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }
    
    private func updateCalendar() {
        monthLabel.text = currentDate.monthString
        daysInMonth = generateDaysInMonth(for: currentDate)
        collectionView.reloadData()
        updateStats()
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)!
        let startOfMonth = date.startOfMonth()
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private func loadData() {
        calendarEntries = DataManager.shared.loadCalendarEntries()
        updateCalendar()
    }
    
    private func updateStats() {
        let monthEntries = calendarEntries.filter {
            Calendar.current.isDate($0.date, equalTo: currentDate, toGranularity: .month)
        }
        
        let itemCounts = monthEntries.reduce(into: [UUID: Int]()) { counts, entry in
            if let outfit = DataManager.shared.loadOutfits().first(where: { $0.id == entry.outfitID }) {
                outfit.itemIDs.forEach { itemID in
                    counts[itemID, default: 0] += 1
                }
            }
        }
        
        if let mostWornID = itemCounts.max(by: { $0.value < $1.value }),
           let item = DataManager.shared.getClothingItem(by: mostWornID.key) {
            statsLabel.text = "Most worn: \(item.name) (\(mostWornID.value)x)"
        } else {
            statsLabel.text = "No outfits this month"
        }
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        updateCalendar()
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        updateCalendar()
    }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        let date = daysInMonth[indexPath.item]
        let day = Calendar.current.component(.day, from: date)
        let isToday = Calendar.current.isDateInToday(date)
        
        let entry = calendarEntries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
        var outfit: Outfit?
        if let entry = entry {
            outfit = DataManager.shared.loadOutfits().first { $0.id == entry.outfitID }
        }
        
        cell.configure(day: day, outfit: outfit, isToday: isToday)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = daysInMonth[indexPath.item]
        
        let alert = UIAlertController(title: "Select Outfit", message: "Choose outfit for this day", preferredStyle: .actionSheet)
        
        let outfits = DataManager.shared.loadOutfits()
        for outfit in outfits {
            alert.addAction(UIAlertAction(title: outfit.name, style: .default) { _ in
                let entry = CalendarEntry(date: date, outfitID: outfit.id)
                DataManager.shared.addCalendarEntry(entry)
                self.loadData()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
