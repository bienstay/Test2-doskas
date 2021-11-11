//
//  HomeCollectionViewController.swift
//  Test2
//
//  Created by maciulek on 12/10/2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!

    private enum Section: Int, CaseIterable {
        case header = 0
        case title = 1
        case items = 2
        static var numberOfSections: Int { return self.allCases.count }
    }

    enum Items: String, CaseIterable {
        // raw value is the icon name
        case news = "News"
        case activities = "Activities"
        case map = "Map"
        case watersports = "Watersports"
        case adoptACoral = "AdoptAcoral"
        case kidsClub = "KidsClub"

        static func getString(item: Items) -> String {
            switch item {
            case .news: return .news
            case .activities: return .activities
            case .map: return .map
            case .watersports: return .waterSports
            case .adoptACoral: return .adoptACoral
            case .kidsClub: return .kidsClub
            }
        }
    }

    //let tempIconNames = ["News", "Activities", "Map", "Watersports", "AdoptAcoral", "KidsClub", "Sugar", "Soap", "022-room key", "033-bucket"]
    let tempIconColors: [UIColor] = [.color1, .color2, .color3, .lightGray, .color2, .color1, .color3]

    var onboardingShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(collectionView: collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(onHotelInfoUpdated(_:)), name: .hotelInfoUpdated, object: nil)

        tabBarController?.viewControllers?[0].tabBarItem.title = .home
        tabBarController?.viewControllers?[1].tabBarItem.title = .food
        tabBarController?.viewControllers?[2].tabBarItem.title = .room
        tabBarController?.viewControllers?[3].tabBarItem.title = .orders
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.contentInsetAdjustmentBehavior = .never   // hides the navigation bar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        if !onboardingShown {
            let vc = OnboardingPageViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            onboardingShown = true
        }
    }

    @objc func onHotelInfoUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadSections([Section.header.rawValue, Section.title.rawValue])
        }
    }

    @objc func didTap(sender: UITapGestureRecognizer) {
        ConfigViewController.showPopup(parentVC: self)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .header: return 1
        case .title: return 1
        case .items: return Items.allCases.count
        case .none: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHeaderCell", for: indexPath) as! HomeHeaderCell
            cell.tapClosure = { ConfigViewController.showPopup(parentVC: self) }
            cell.draw(imageURL: hotel.image)
            return cell
        case .title:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTitleCell", for: indexPath) as! HomeTitleCell
            cell.draw(title: hotel.name)
            return cell
        case .items:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemsCell", for: indexPath) as! HomeItemsCell
            cell.tag = indexPath.row
            //cell.draw(title: Items.allCases[indexPath.row].rawValue, pictureName: tempIconNames[indexPath.row], color: tempIconColors[indexPath.row])
            cell.draw(item: Items.allCases[indexPath.row], index: indexPath.row)
            return cell
        case .none:
            Log.log(level: .ERROR, "invalid section in cellForItem")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .items:
            let item: Items = Items.allCases[indexPath.row]
            switch item {
            case .news:         _ = pushOrPresent(storyBoard: "News", id: "News")
            case .activities:   _ = pushViewController(storyBoard: "Activities", id: "Activities")
            case .map:          _ = pushViewController(storyBoard: "Map", id: "mapViewController")
            case .watersports:  _ = pushViewController(storyBoard: "WaterSports", id: "WaterSports")
            case .adoptACoral:
                let vc = pushOrPresent(storyBoard: "Info", id: "Info") as! InfoViewController
                vc.infoItem = hotel.infoItems[0]    // TODO
            case .kidsClub:     _ = pushViewController(storyBoard: "Activities", id: "Activities")
            }
            default: break
        }
    }

    @IBAction func chatButtonPressed(_ sender: UIButton) {
        _ = pushViewController(storyBoard: "Chat", id: "Chat")
    }
}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    private static let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch Section(rawValue: indexPath.section) {
        case .header:
            return CGSize(width: collectionView.bounds.width, height: floor(collectionView.bounds.width*3.0/4.0))
        case .title:
            //let h = calculateLabelHeight(s: hotel.name, width: collectionView.bounds.width)
            return CGSize(width: collectionView.bounds.width, height: 80)
        case .items:
            let width = collectionView.bounds.width
            let numberOfItemsPerRow: CGFloat = 2
            let spacing: CGFloat = HomeCollectionViewController.sectionInsets.left
            let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
            let itemDimension = floor(availableWidth / numberOfItemsPerRow)
            // calculate the height of a sample one line text and then the height of the full text
            // let hOneLine = calculateLabelHeight(s: "bla", width: itemDimension)
            // let h = calculateLabelHeight(s: Items.allCases[indexPath.row].rawValue, width: itemDimension)
            // return CGSize(width: itemDimension, height: itemDimension - hOneLine + h)
            return CGSize(width: itemDimension, height: itemDimension)
        case .none:
            Log.log(level: .ERROR, "Invalid section in sizeFotItemAt")
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        switch Section(rawValue: section) {
        case .header: return UIEdgeInsets.zero
        case .title: return UIEdgeInsets(top: 12.0, left: 0.0, bottom: 4.0, right: 0.0)
        case .items: return HomeCollectionViewController.sectionInsets
        case .none:
            Log.log(level: .ERROR, "Invalid section in insetForSectionAt")
            return UIEdgeInsets.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        switch Section(rawValue: section) {
        case .header: return 0
        case .title: return 0
        case .items: return HomeCollectionViewController.sectionInsets.left
        case .none:
            Log.log(level: .ERROR, "Invalid section in minimumLineSpacing")
            return 0
        }
    }
}


class HomeHeaderCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var chatButton: UIButton!

    var tapClosure: (() -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTapsRequired = 3
        picture.addGestureRecognizer(tap)
        picture.isUserInteractionEnabled = true
        chatButton.backgroundColor = .orange
        chatButton.setBackgroundImage(UIImage(named: "Chat"), for: .normal)
    }

    @objc func didTap() {
        tapClosure?()
    }

    func draw(imageURL: String) {
        picture.kf.setImage(with: URL(string: imageURL))
    }

    // width constrain for ipad is set to 100 but is still 60 in awakeFromNib() and draw()
    override func layoutSubviews() {
        let width = chatButton.frame.width
        chatButton.layer.cornerRadius =  width / 2
    }
}

class HomeTitleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.backgroundColor = .offWhiteVeryLight
        contentView.backgroundColor = .offWhiteVeryLight
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func draw(title: String) {
        titleLabel.text = title
    }
}

class HomeItemsCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundColorView: UIView!
    let iconColors: [UIColor] = [.color1, .color2, .color3, .lightGray, .color2, .color1, .color3]

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
    }

    func draw(title: String, pictureName: String, color: UIColor) {
        titleLabel.text = title
        let border = -12.0
        picture.image = UIImage(named: pictureName)?.withAlignmentRectInsets(UIEdgeInsets(top: border, left: border, bottom: border, right: border))
        titleLabel.superview?.backgroundColor = color
        backgroundColorView.backgroundColor = color
    }

    func draw(item:HomeCollectionViewController.Items, index: Int) {
        titleLabel.text = HomeCollectionViewController.Items.getString(item: item)
        let border = -12.0
        picture.image = UIImage(named: item.rawValue)?.withAlignmentRectInsets(UIEdgeInsets(top: border, left: border, bottom: border, right: border))
        titleLabel.superview?.backgroundColor = iconColors[index]
        backgroundColorView.backgroundColor = iconColors[index]
    }
}

func calculateLabelHeight(s: String, width: CGFloat) -> CGFloat {
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = UIFont.preferredFont(forTextStyle: .title1)
    label.text = s
    label.sizeToFit()

    return label.frame.height
}
              

extension String {
    static let news = NSLocalizedString("News", comment: "News")
    static let activities = NSLocalizedString("Activities", comment: "Activities")
    static let waterSports = NSLocalizedString("Water Sports", comment: "Water Sports")
    static let map = NSLocalizedString("Map", comment: "Map")
    static let adoptACoral = NSLocalizedString("Adopt a Coral", comment: "Adopt a Coral")
    static let kidsClub = NSLocalizedString("Kids Club", comment: "Kids Club")
}

extension String {
    static let home = NSLocalizedString("Home", comment: "Tab 0")
    static let food = NSLocalizedString("Food", comment: "Tab 1")
    static let room = NSLocalizedString("Room", comment: "Tab 2")
    static let orders = NSLocalizedString("Orders", comment: "Tab 3")
}

extension String {
    static let toiletries = NSLocalizedString("Toiletries", comment: "Toiletries")
    static let bathAmenities = NSLocalizedString("Bath Amenities", comment: "Bath Amenities")
    static let roomAmenities = NSLocalizedString("Room Amenities", comment: "Room Amenities")
    static let roomConsumables = NSLocalizedString("Room Consumables", comment: "Room Consumables")
}

extension String {
    static let roomService = NSLocalizedString("In-room dining", comment: "In-room dining")
    static let maintenance = NSLocalizedString("Maintenance", comment: "Maintenance")
    static let cleaning = NSLocalizedString("Cleaning", comment: "Cleaning")
    static let luggageService = NSLocalizedString("Luggage", comment: "Luggage")
    static let buggy = NSLocalizedString("Buggy", comment: "Buggy")
    static let roomItems = NSLocalizedString("Room Items", comment: "Room Items")
}

extension String {
    static let create = NSLocalizedString("Create", comment: "Create")
    static let confirm = NSLocalizedString("Confirm", comment: "Confirm")
    static let finish = NSLocalizedString("Finish", comment: "Finish")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let created = NSLocalizedString("Created", comment: "Created")
    static let confirmed = NSLocalizedString("Confirmed", comment: "Confirmed")
    static let delivered = NSLocalizedString("Delivered", comment: "Delivered")
    static let canceled = NSLocalizedString("Canceled", comment: "Canceled")
}

extension String {
    static let order = NSLocalizedString("Order", comment: "Order")
    static let newOrder = NSLocalizedString("New Order", comment: "New Order")
    static let comment = NSLocalizedString("Comment", comment: "Comment")
    static let send = NSLocalizedString("Send", comment: "Send")
    static let proceed = NSLocalizedString("Proceed", comment: "Proceed")
    static let description = NSLocalizedString("Description", comment: "Description")
}

extension String {
    static let yes = NSLocalizedString("Yes", comment: "Yes")
    static let no = NSLocalizedString("No", comment: "No")
    static let ok = NSLocalizedString("OK", comment: "OK")
}

extension String {
    static let roomItemsList: [String:[String:String]] =
    ["pl": [
        "Bath towel" : "Ręcznik kąpielowy",
        "Hand towel" : "Ręcznik do rąk",
        "Floor towel": "Ręcznik na podłogę",
        "Beach towel": "Ręcznik na plażę",
        "Slippers" : "Kapcie",
        "Bathrobe" : "Szlafrok",
        "Feather pillow" : "Poduszka z pierza",
        "Foam pillow" : "Poduszka sztuczna",
        "Blanket" : "Koc",
        "Soap" : "Mydło",
        "Shampoo" : "Szampon",
        "Conditioner" : "Odżywka do włosów",
        "Shower Gel" : "Płyn pod prysznic",
        "Body Lotion" : "Balsam do ciała",
        "Dental Kit" : "Zestaw dentystyczny",
        "Shaving Kit" : "Zestaw do golenia",
        "Shower Cap" : "Czepek do kąpieli",
        "Comb" : "Grzebień",
        "Toilet Paper" : "Papier toaletowy",
        "Cotton Buds" : "Patyczki higieniczne",
        "Ice": "Lód",
        "Tea" : "Herbata",
        "Coffee" : "Kawa",
        "Sugar" : "Cukier",
        "Milk" : "Mleko"
    ]
    ]
}
