//
//  HomeCollectionViewController.swift
//  Test2
//
//  Created by maciulek on 12/10/2021.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var emulationLabel: UILabel!
    @IBOutlet weak var connectionLostLabel: UILabel!
    var menu: MenuView!

    var squareSize: Double = 0.0
    var locationManager:CLLocationManager!

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
        case offers = "Offers"
        case map = "Map"
        //case watersports = "Watersports"
        //case adoptACoral = "AdoptAcoral"
        //case kidsClub = "KidsClub"

        static func getString(item: Items) -> String {
            switch item {
            case .news: return .news
            case .activities: return .activities
            case .offers: return .offers
            case .map: return .map
            //case .watersports: return .waterSports
            //case .adoptACoral: return .adoptACoral
            //case .kidsClub: return .kidsClub
            }
        }
    }

    @IBAction func menuBarButtonPressed(_ sender: Any) {
        menu.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(collectionView: collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(onHotelInfoUpdated(_:)), name: .hotelInfoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatMessagesUpdated(_:)), name: .chatMessageAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatMessagesUpdated(_:)), name: .chatMessageUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatMessagesUpdated(_:)), name: .chatMessageDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectionStatusUpdated(_:)), name: .connectionStatusUpdated, object: nil)

        tabBarController?.viewControllers?[0].tabBarItem.title = .home
        tabBarController?.viewControllers?[1].tabBarItem.title = .food
        tabBarController?.viewControllers?[2].tabBarItem.title = .room
        tabBarController?.viewControllers?[3].tabBarItem.title = .orders

        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.requestAlwaysAuthorization()    // result in the callback below
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }

        menu = MenuView(parentView: view, headerText: "Menu")
        if phoneUser.isStaff {
            menu.addItem(label: "Change password") { [weak self] in
                if let self = self {
                    _ = self.presentModal(storyBoard: "Users", id: "ChangePassword")
                }
            }
        }
        if phoneUser.isAllowed(to: .manageUsers) {
            menu.addItem(label: "Manage users") { [weak self] in
                if let self = self {
                    _ = self.presentModal(storyBoard: "Users", id: "Users")
                    //_ = self.pushViewController(storyBoard: "Users", id: "Users")
                }
            }
        }
        menu.addItem(label: "Show onboarding") { [weak self] in
            let vc = OnboardingPageViewController()
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }
        menu.addSeparator()
        menu.addItem(label: "Log out") { [weak self] in
            print("Logging out...")
            self?.logOutAndGoToScannerView()
        }
    }

    func logOutAndGoToScannerView() {
        _ = authProxy.logout()
        dbProxy.removeAllObservers()
        hotel = Hotel()
        phoneUser = PhoneUser()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.transitionToScanner()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView.contentInsetAdjustmentBehavior = .never   // hides the navigation bar
        //navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)

        statusView.isUserInteractionEnabled = false
        updateStatusView()
        
        tabBarController?.tabBar.isHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "OnboardingShown") {
            let vc = OnboardingPageViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "OnboardingShown") //Bool
        }
    }

    @objc func onHotelInfoUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadSections([Section.header.rawValue, Section.title.rawValue])
        }
    }

    @objc func onChatMessagesUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadSections([Section.header.rawValue])
        }
    }

    @objc func onConnectionStatusUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.updateStatusView()
        }
    }
    
    func updateStatusView() {
        connectionLostLabel.isHidden = dbProxy.isConnected
        emulationLabel.isHidden = !(UIApplication.shared.delegate as! AppDelegate).useEmulator
        statusView.isHidden = connectionLostLabel.isHidden && emulationLabel.isHidden
    }

    func askToResetUserDefaults() {
        //ConfigViewController.showPopup(parentVC: self)
        let cancelAlert = UIAlertController(title: "Reset Memory", message: "Erase UserDefaults?", preferredStyle: UIAlertController.Style.alert)
        cancelAlert.addAction(UIAlertAction(title: .yes, style: .destructive, handler: { (action: UIAlertAction!) in
            UserDefaults.standard.set(true, forKey: "resetDefaults")
        }))
        cancelAlert.addAction(UIAlertAction(title: .no, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(cancelAlert, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let location = locations.last! as CLLocation
        //(location.coordinate.latitude)
        //(location.coordinate.longitude)
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //("locations = \(locValue.latitude) \(locValue.longitude)")
        phoneUser.currentLocationLatitude = locValue.latitude
        phoneUser.currentLocationLongitude = locValue.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        Log.log(level: .ERROR, error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse, .authorized:
                    Log.log("Location authorization - \(manager.authorizationStatus) - granted")
                    locationManager.startUpdatingLocation()
                default:
                    Log.log("Location authorization - \(manager.authorizationStatus) - denied")
                    break
            }
        } else {
            let status = CLLocationManager.authorizationStatus()
            switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    Log.log("Location authorization - \(status) - granted")
                case .notDetermined, .restricted, .denied:
                    Log.log("Location authorization - \(status) - denied")
                @unknown default:
                    break
            }
        }
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
            cell.tapClosure = { [weak self] in self?.askToResetUserDefaults() }
            //cell.tapClosure = { ConfigViewController.showPopup(parentVC: self) }
            cell.swipeClosure = { [weak self] in  _ = self?.pushViewController(storyBoard: "Home", id: "NewHotel") }
            cell.draw(title:hotel.name, imageURL: hotel.image)
            return cell
        case .title:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTitleCell", for: indexPath) as! HomeTitleCell
            cell.tapClosure = { [weak self] in
                let vc = self?.pushViewController(storyBoard: "Home", id: "NewHotel") as! UpdateHotelInfoViewController
                vc.hotelToEdit = hotel
            }
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
                case .news:         _ = pushViewController(storyBoard: "News", id: "News")
                case .activities:   _ = pushViewController(storyBoard: "Activities", id: "Activities")
                case .offers:       _ = pushViewController(storyBoard: "Offers", id: "Offers")
                //case .map:          _ = pushViewController(storyBoard: "Main", id: "NFCReader")
                case .map:          //_ = pushViewController(storyBoard: "Map", id: "mapViewController")
                                        logOutAndGoToScannerView()
                //case .watersports:  _ = pushViewController(storyBoard: "WaterSports", id: "WaterSports")
            }
        default: break
        }
    }

    @IBAction func chatButtonPressed(_ sender: UIButton) {
        _ = pushViewController(storyBoard: "Chat", id: phoneUser.isStaff ? "ChatList" : "Chat")
    }

    @IBAction func buggyButtonPressed(_ sender: UIButton) {
        let vc = pushViewController(storyBoard: "OrderSummary", id: "BuggyOrder") as! BuggyOrderViewController
        vc.category = Order.Category.Buggy
    }

    @IBAction func socialButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: UIApplication.tryURL(urls: [
            hotel.socialURLs["instagram"] ?? "",
            hotel.socialURLs["instagramweb"] ?? ""
            //"instagram://user?username=ritzcarltonkohsamui",
            //"https://www.instagram.com/ritzcarltonkohsamui"
        ])
        case 1: UIApplication.tryURL(urls: [
            hotel.socialURLs["facebook"] ?? "",
            hotel.socialURLs["facebookweb"] ?? ""
//            "fb://profile?id=ritzcarltonkohsamui", // App
//            "https://www.facebook.com/ritzcarltonkohsamui" // Website if app fails
            ])
        case 2: UIApplication.tryURL(urls: [
            hotel.socialURLs["twitter"] ?? "",
            hotel.socialURLs["twitterweb"] ?? ""
//            "twitter:///user?screen_name=RitzCarlton",
//            "https://twitter.com/RitzCarlton"
            ])
        case 3: UIApplication.tryURL(urls: [
            hotel.socialURLs["tripadvisor"] ?? "",
            hotel.socialURLs["tripadvisorweb"] ?? ""
            //"https://www.tripadvisor.com/Hotel_Review-g1179396-d12504573-Reviews-The_Ritz_Carlton_Koh_Samui-Bophut_Ko_Samui_Surat_Thani_Province.html"
        ])
        case 4: UIApplication.tryURL(urls: [
            hotel.socialURLs["bonvoy"] ?? "",
            hotel.socialURLs["bonvoyweb"] ?? ""
            //"https://www.ritzcarlton.com/en/hotels/koh-samui"
            ])
        default: break
        }
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
            return CGSize(width: collectionView.bounds.width, height: 40)
        case .items:
            let width = collectionView.bounds.width
            let numberOfItemsPerRow: CGFloat = 2
            let spacing: CGFloat = HomeCollectionViewController.sectionInsets.left
            let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
            let itemDimension = floor(availableWidth / numberOfItemsPerRow)
            return CGSize(width: itemDimension, height: itemDimension)
        case .none:
            Log.log(level: .ERROR, "Invalid section in sizeFotItemAt")
            return CGSize.zero
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()  // needed to resize after device rotation
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
    @IBOutlet weak var buggyButton: UIButton!
    @IBOutlet weak var unreadChatLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    var tapClosure: (() -> ())? = nil
    var swipeClosure: (() -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()

        picture.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap3.numberOfTapsRequired = 3
        picture.addGestureRecognizer(tap3)
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        swipe.direction = .right
        picture.addGestureRecognizer(swipe)

        chatButton.backgroundColor = .orange
        chatButton.setBackgroundImage(UIImage(named: "Chat"), for: .normal)
        chatButton.isHidden = true
        unreadChatLabel.layer.cornerRadius = 20
        unreadChatLabel.layer.masksToBounds = true
        unreadChatLabel.layer.backgroundColor = UIColor.red.cgColor
        unreadChatLabel.textAlignment = .center
        unreadChatLabel.textColor = .white

        buggyButton.backgroundColor = .orange
        buggyButton.setBackgroundImage(UIImage(named: "buggyIcon2"), for: .normal)
        buggyButton.isHidden = true
    }

    @objc func didTap() {
        tapClosure?()
    }

    @objc func didSwipe() {
        swipeClosure?()
    }

    func draw(title: String, imageURL: String) {
        picture.kf.setImage(with: URL(string: imageURL)) { result in
            switch result {
            case .success:
                break //print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        titleLabel.text = title
        let unreadCount = phoneUser.unreadChatCount()
        unreadChatLabel.text = String(unreadCount)
        unreadChatLabel.isHidden = unreadCount < 1
    }

    // width constrain for ipad is set to 100 but is still 60 in awakeFromNib() and draw()
    override func layoutSubviews() {
        let width = chatButton.frame.width
        chatButton.layer.cornerRadius =  width / 2
        buggyButton.layer.cornerRadius =  width / 2
    }
}

class HomeTitleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    var tapClosure: (() -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @objc func didTap() {
        tapClosure?()
    }

    func draw(title: String) {
        //titleLabel.text = title
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
    static let offers = NSLocalizedString("Offers", comment: "Offers")
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


extension HomeCollectionViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard controller.documentPickerMode == .import, let url = urls.first else { return }

        let s =  try! String(contentsOfFile: url.path)
        print(s)
        controller.dismiss(animated: true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
