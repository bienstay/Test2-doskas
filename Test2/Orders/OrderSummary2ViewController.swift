//
//  OrderSummary2ViewController.swift
//  Test2
//
//  Created by maciulek on 27/07/2022.
//

import UIKit
import SwiftUI
import MapKit

class OrderSummary2ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var idLabel: UILabel!
    var statusChangeButton: UIBarButtonItem? = nil

    var order: Order6 = Order6(category: .None)

    private enum Section: Int, CaseIterable {
        case header
        case data
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        idLabel.text = order.id

//        if #available(iOS 15.0, *) {
//            tableView.sectionHeaderTopPadding = 0
//        }

        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)

        let barButton = createBarButtonItem(target: self, action: #selector(statusChangeButtonPressed))
        statusChangeButton = barButton
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(largeTitle: false, title: .order + " " + String(order.number) + " - " + order.category.toString())
        updateStatusLabelsAndButtons()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch order.category {
        case .RoomItems, .RoomService, .Buggy: return 2
        default: return 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
            case .header: return 1
            case .data:
                switch order.category {
                    case .RoomItems: return order.roomItems.count
                    case .RoomService: return order.foodItems.count
                    case .Buggy:
                        switch order.buggyItem?.locationType {
                            case .GPS, .Photo: return 1
                            default: return 0
                        }
                    default: return 0
                }
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .header:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? OrderSummaryHeaderCell {
                cell.configure(order: order)
                return cell
            }
        case .data:
            switch order.category {
            case .RoomItems:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "RoomItemCell", for: indexPath) as? OrderSummaryRoomItemCell {
                    cell.configure(item: order.roomItems[indexPath.row])
                    return cell
                }
            case .RoomService:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath) as? OrderSummaryFoodItemCell {
                    cell.configure(item: order.foodItems[indexPath.row])
                    return cell
                }
            case .Buggy:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "BuggyCell", for: indexPath) as? OrderSummaryBuggyCell {
                    cell.configure(item: order.buggyItem!)
                    return cell
                }
            default: break
            }
        default: break
        }
        return UITableViewCell()
    }
}

extension OrderSummary2ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .data:
            switch order.category {
                case .RoomItems: return "Room Items"
                case .RoomService: return "Food Items"
                case .Buggy: return "Location - " + (order.buggyItem?.locationType.toString() ?? "")
                default: return nil
            }
        default: return nil
        }
    }
}

extension OrderSummary2ViewController {
    @IBAction func statusChangeButtonPressed(_ sender: UIBarButtonItem) {
        switch order.status {
        case .CREATED:
            if phoneUser.isStaff {
                order.setStatus(status: .CONFIRMED(at: Date(), by: phoneUser.displayName))
                dbProxy.updateOrderStatus(order: order)
                //dbProxy.updateOrderStatus(orderId: order.id, newStatus: .CONFIRMED(at: Date(), by: phoneUser.displayName), confirmedBy: phoneUser.displayName)
            } else {
                askToCancel()
            }
        case .CONFIRMED:
            if phoneUser.isStaff {
                order.setStatus(status: .DELIVERED(at: Date(), by: phoneUser.displayName))
                dbProxy.updateOrderStatus(order: order)
                //dbProxy.updateOrderStatus(orderId: order.id, newStatus: .DELIVERED(at: Date(), by: phoneUser.displayName), deliveredBy: phoneUser.displayName)
            }
        default: break
        }
    }

    func askToCancel() {
        let cancelAlert = UIAlertController(title: .cancel.localizedUppercase, message: .confirm, preferredStyle: UIAlertController.Style.alert)
        cancelAlert.addAction(UIAlertAction(title: .yes, style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
            //dbProxy.updateOrderStatus(orderId: self.order.id, newStatus: .CANCELED(at: Date(), by: phoneUser.displayName), canceledBy: phoneUser.displayName)
            guard let self = self else { return }
            self.order.setStatus(status: .CANCELED(at: Date(), by: phoneUser.displayName))
            dbProxy.updateOrderStatus(order: self.order)
        }))
        cancelAlert.addAction(UIAlertAction(title: .no, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(cancelAlert, animated: true, completion: nil)
    }
    
    func updateStatusLabelsAndButtons() {
        guard let button = statusChangeButton?.customView as? UIButton else { return }
        if phoneUser.isAllowed(to: .manageOrders) {
            button.isHidden = false
            switch order.status {
            case .CREATED:   button.setTitle(.confirm, for: .normal)
            case .CONFIRMED: button.setTitle(.finish, for: .normal)
            default:
                button.isHidden = true
                button.setTitle("", for: .normal)
            }
        }
        else if !phoneUser.isStaff {
            switch order.status {
            case .CREATED:
                button.setTitle(.cancel, for: .normal)
                button.isHidden = false
            default:
                button.setTitle("", for: .normal)
                button.isHidden = true
            }
        }
        else {
            button.isHidden = true
        }
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        if let or = phoneUser.orders6.first(where: { $0.id == order.id }) {
            order = or
        }
        DispatchQueue.main.async {
            self.updateStatusLabelsAndButtons()
            self.tableView.reloadData()
        }
    }

}

class OrderSummaryHeaderCell: UITableViewCell {
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusHistoryLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var categoryPicture: UIImageView!
    @IBOutlet weak var categoryView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
/*
        categoryView.backgroundColor = UIColor.clear
        categoryView.layer.shadowColor = UIColor.black.cgColor
        categoryView.layer.shadowOffset = CGSize(width: 3, height: 3)
        categoryView.layer.shadowOpacity = 0.7
        categoryView.layer.shadowRadius = 4.0

        categoryPicture.backgroundColor = .white
        categoryPicture.layer.cornerRadius = categoryPicture.frame.width/2
        categoryPicture.layer.borderColor = UIColor.gray.cgColor
        categoryPicture.layer.masksToBounds = true
 */
    }

    func configure(order: Order6) {
        roomNumberLabel.text = String(order.roomNumber)
        statusLabel.text = order.status.toString()
        switch order.status {
        case .CREATED(_, _): statusLabel.textColor = .systemRed
        case .CONFIRMED(_, _): statusLabel.textColor = .systemBlue
        case .DELIVERED(_, _): statusLabel.textColor = .systemGreen
        case .CANCELED(_, _): statusLabel.textColor = .systemGray
        default: break
        }

        var text = ""
        for h in order.statusHistory {
            var date: Date = Date()
            var user: String = ""
            switch h {
            case .CREATED(let at, let by): date = at; user = by
            case .CONFIRMED(let at, let by): date = at; user = by
            case .DELIVERED(let at, let by): date = at; user = by
            case .CANCELED(let at, let by): date = at; user = by
            default: break
            }
            text += "\(h.toString()) \t \(user) \t \(date.formatForDisplay())\n"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: 150),
            NSTextTab(textAlignment: .right, location: frame.width - 60)
        ]
        let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        statusHistoryLabel.attributedText = attributedText
        commentLabel.text = order.comment
        categoryPicture.image = UIImage(named: order.category.rawValue)
    }
}

class OrderSummaryRoomItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
    }

    func configure(item: RoomOrderItem) {
        titleLabel.text = item.item.name
        quantityLabel.text = String(item.quantity)
        picture.image = UIImage(named: item.item.picture)
        if let hexColor = Int(item.item.color, radix: 16) {
            picture.backgroundColor = UIColor(hexColor)
        } else {
            picture.backgroundColor = .gray
        }
    }
}

class OrderSummaryFoodItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var addonsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        picture.layer.cornerRadius = 8
        picture.layer.masksToBounds = true
    }

    func configure(item: FoodOrderItem) {
        titleLabel.text = item.item.title
        quantityLabel.text = String(item.quantity)
        priceLabel.text = String(item.totalPrice)
        //picture.image = UIImage(named: "foodPlaceholder")
        if let img = item.item.img {
            picture.image = UIImage(named: img)
        }
        choiceLabel.text = ""
        choiceLabel.isHidden = item.choiceIndex == nil
        if let choiceIndex = item.choiceIndex {
            choiceLabel.text = item.item.choices?[choiceIndex].title
        }
        addonsLabel.text = ""
        addonsLabel.isHidden = item.addonCount == nil
        if let addonCount = item.addonCount {
            var printNewline = false
            for i in 0...addonCount.count - 1 {
                let count = addonCount[i]
                let title = item.item.addons?[i].title ?? ""
                if count > 0 {
                    if printNewline { addonsLabel.text?.append("\n") }
                    addonsLabel.text?.append("\(count)  \(title)")
                    printNewline = true
                }
            }
        }
    }
}

class OrderSummaryBuggyCell: UITableViewCell {
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var pictureContainer: UIView!
    @IBOutlet weak var roomNrContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    func configure(item: BuggyOrderItem) {
        mapContainer.isHidden = true
        mapContainer.layer.cornerRadius = 12
        mapContainer.layer.masksToBounds = true
        pictureContainer.isHidden = true
        pictureContainer.layer.masksToBounds = true
        pictureContainer.layer.cornerRadius = 12
        roomNrContainer.isHidden = true
        switch item.locationType {
//        case .Room:
//            roomLabel.text = .room
//            roomNrContainer.isHidden = false
        case .Photo:
            picture.kf.setImage(with: URL(string: item.locationData)!)
            pictureContainer.isHidden = false
        case .GPS:
            let coordinates = item.locationData.components(separatedBy: [",", " "])
            if coordinates.count == 2 {
                let latitude = Double(coordinates[0]) ?? 0.0
                let longitude = Double(coordinates[1]) ?? 0.0
                setupMap(mapView: mapView, latitude: latitude, longitude: longitude)
                mapContainer.isHidden = false
            }
        default: break
        }
        layoutSubviews()
    }

    func setupMap(mapView:MKMapView, latitude: Double, longitude: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            Log.log(level: .ERROR, "Invalid coordinates")
            return
        }
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(region, animated: false)
        mapView.addAnnotation(annotation)
        mapView.showsCompass = false
        mapView.showsScale = true
        mapView.showsTraffic = false
        mapView.showsPointsOfInterest = false
        mapView.showsBuildings = true
    }
}
