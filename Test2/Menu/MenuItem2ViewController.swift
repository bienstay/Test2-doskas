//
//  MenuItem2ViewController.swift
//  Test2
//
//  Created by maciulek on 15/07/2022.
//

import UIKit

class MenuItem2ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    enum Sections:Int, CaseIterable {
        case header
        case attributes
        case text
        case price
        case choices
        case addons
        case total
        case empty
    }
    var foodOrder: FoodOrderItem? = nil
    var choiceIndex: Int = 0
    var menuItem: MenuItem = MenuItem()
    var completionHandler: ((FoodOrderItem) -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(collectionView: collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInsetAdjustmentBehavior = .never

        if let foodOrder = foodOrder {
            menuItem = foodOrder.item
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar(collectionView: collectionView)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Sections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .header: return 1
        case .attributes: return menuItem.foodAttributes.count
        case .text: return 1
        case .price: return 1
        case .choices: return menuItem.choices?.isEmpty ?? true ? 0 : 1
        case .addons: return menuItem.addons?.count ?? 0
        case .total: return foodOrder != nil ? 1 : 0
        default: return 0
        }
    }

    @IBAction func decreaseCount(_ sender: UIButton) {
        if foodOrder?.quantity ?? 0 > 0 { foodOrder?.quantity -= 1 }
        collectionView.reloadSections([Sections.price.rawValue, Sections.total.rawValue])
    }
    
    @IBAction func increaseCount(_ sender: UIButton) {
        if foodOrder?.quantity ?? 10 < 9 { foodOrder?.quantity += 1 }   // TODO - ugly
        collectionView.reloadSections([Sections.price.rawValue, Sections.total.rawValue])
    }

    @IBAction func choiceMade(_ sender: UISegmentedControl) {
        foodOrder?.choiceIndex = sender.selectedSegmentIndex
        choiceIndex = sender.selectedSegmentIndex
        collectionView.reloadSections([Sections.price.rawValue, Sections.total.rawValue])
    }

    @IBAction func addonChanged(_ sender: UIStepper) {
        foodOrder?.addonCount?[sender.tag] = Int(sender.value)
        collectionView.reloadSections([Sections.addons.rawValue, Sections.total.rawValue])
    }

    @IBAction func addToOrder(_ sender: UIButton) {
        guard let foodOrder = foodOrder else { return }
        completionHandler?(foodOrder)
        navigationController?.popViewController(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .header:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as? HeaderCell {
                cell.configure(menuItem: menuItem)
                return cell
            }
        case .attributes:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttributesCell", for: indexPath) as? AttributesCell {
                cell.attributeLabel.text = menuItem.foodAttributes[indexPath.row]
                return cell
            }
        case .text:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as? TextCell {
                cell.configure(menuItem: menuItem)
                return cell
            }
        case .price:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceCell", for: indexPath) as? PriceCell {
                cell.configure(menuItem: menuItem, foodOrder: foodOrder, choiceIndex: choiceIndex)
                return cell
            }
        case .choices:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChoicesCell", for: indexPath) as? ChoicesCell {
                cell.configure(menuItem: menuItem)
                return cell
            }
        case .addons:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddonsCell", for: indexPath) as? AddonsCell,
               let addons = menuItem.addons {
                cell.configure(title: addons[indexPath.row].title, price: addons[indexPath.row].price, count: foodOrder?.addonCount?[indexPath.row] ?? 0, isOrder: foodOrder != nil)
                cell.stepper.tag = indexPath.row
                return cell
            }
        case .total:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TotalCell", for: indexPath) as? TotalCell {
                cell.configure(food: foodOrder)
                return cell
            }
        default:
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }

    private func createRowSection(showHeader: Bool = false, showFooter: Bool = false, bottomMargin: CGFloat = 32.0) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(20))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(20))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        if showHeader {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [sectionHeader]
        }
        if showFooter {
            let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
            section.boundarySupplementaryItems = [sectionFooter]
        }
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: bottomMargin, trailing: 16)
        return section
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            switch Sections(rawValue: section) {
            case .header:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
                return section

            case .attributes:
                let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(5), heightDimension: .estimated(5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(5), heightDimension:  .estimated(5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 8

                return section

            case .text:
                return self?.createRowSection()

            case .price:
                return self?.createRowSection(bottomMargin: 24)

            case .choices:
                if self?.menuItem.choices?.isEmpty ?? true {
                    return nil
                } else {
                    return self?.createRowSection(showHeader: true)
                }

            case .addons:
                return self?.createRowSection(showHeader: !(self?.menuItem.addons?.isEmpty ?? true))

            case .total:
                return self?.createRowSection(bottomMargin: 48)

            case .empty:
                return self?.createRowSection(showFooter: true)

//            case .review:
//                return self?.reviewsManager.reviews.isEmpty ?? true ? nil : ReviewCollectionViewCell.createLayoutSection()
            default:
                return nil
            }
        }
        
        return layout
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RowSectionFooter", for: indexPath)// as? HeaderSupplementaryView
            return footerView
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RowSectionHeader", for: indexPath) as! RowHeader
            switch Sections(rawValue: indexPath.section) {
            case .choices: headerView.headerLabel.text = "Choose:"
            case .addons: headerView.headerLabel.text = "Add:"
            default: break
            }
            return headerView
        default:
            break
        }
        return UICollectionReusableView()
    }
}

class HeaderCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    func configure(menuItem: MenuItem) {
        if let img = menuItem.img, let url = URL(string: img) {
            picture.kf.setImage(with: url)
        } else {
            picture.image = UIImage(named: "foodPlaceholder")
        }
    }
}

class AttributesCell: UICollectionViewCell {
    @IBOutlet weak var attributeLabel: UILabel!
    func configure(attribute: String) {
        attributeLabel.text = attribute
    }
}

class TextCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    func configure(menuItem: MenuItem) {
        titleLabel.text = menuItem.title
        textLabel.text = menuItem.text
    }
}

class PriceCell: UICollectionViewCell {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabelLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
//    @IBAction func minusButtonPressed(sender: UIButton) {
//        buttonAction?(false)
//    }
//    @IBAction func plusButtonPressed(sender: UIButton) {
//        buttonAction?(true)
//    }
//    var buttonAction: ((Bool) -> ())? = nil
//    func configure(menuItem: MenuItem, choice: Int, quantity: Int, buttonAction: @escaping (Bool) -> ()) {
//        let price = menuItem.choices?[choice].price ?? menuItem.price
//        priceLabel.text = String(price)
//        quantityLabel.text = String(quantity)
//    }
    func configure(menuItem: MenuItem, foodOrder: FoodOrderItem?, choiceIndex: Int) {   // use foodOrder.choiceIndex when order or choiceIndex when not
        quantityLabelLabel.isHidden = (foodOrder == nil)
        quantityLabel.isHidden = (foodOrder == nil)
        minusButton.isHidden = (foodOrder == nil)
        plusButton.isHidden = (foodOrder == nil)
        let price = menuItem.choices?[foodOrder?.choiceIndex ?? choiceIndex].price ?? menuItem.price
        priceLabel.text = String(price)
        quantityLabel.text = String(foodOrder?.quantity ?? 0)
    }
}

extension UISegmentedControl {
   public func replaceSegments<T: Sequence>(withTitles: T) where T.Iterator.Element == String {
        removeAllSegments()
        for title in withTitles {
            insertSegment(withTitle: title, at: numberOfSegments, animated: false)
        }
    }
}

class ChoicesCell: UICollectionViewCell {
    @IBOutlet weak var choice: UISegmentedControl!
    func configure(menuItem: MenuItem) {
        choice.replaceSegments(withTitles: menuItem.choices?.map{$0.title} ?? [])
        choice.selectedSegmentIndex = 0
    }
}

class AddonsCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var quantityLabel: UILabel!
    func configure(title: String, price: Double, count: Int, isOrder: Bool) {
        stepper.isHidden = !isOrder
        quantityLabel.isHidden = !isOrder
        titleLabel.text = title
        priceLabel.text = String(price)
        stepper.value = Double(count)
        quantityLabel.text = String(Int(stepper.value))
    }
}

class TotalCell: UICollectionViewCell {
    @IBOutlet var priceLabel: UILabel!
    func configure(food: FoodOrderItem?) {
        priceLabel.text = String(food?.totalPrice ?? 0)
    }
}

class RowHeader: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
}
