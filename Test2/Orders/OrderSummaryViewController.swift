//
//  OrderSummaryViewController.swift
//  Test2
//
//  Created by maciulek on 30/06/2021.
//

import UIKit
import Kingfisher
import MapKit

class OrderSummaryViewController: UIViewController, UITableViewDataSource {

    var order: Order = Order(category: .None)
    
    enum Sections: Int, CaseIterable {
        case Items = 0
        case GuestComment
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var entireView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var buggyDataView: UIStackView!
    @IBOutlet weak var buggyLocationTypeLabel: UILabel!
    @IBOutlet weak var buggyCommentLabel: UILabel!
    @IBOutlet weak var buggyLocationImage: UIImageView!
    @IBOutlet weak var buggyMapView: MKMapView!


    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var roomNumberLabel: UILabel!

    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var createdStackView: UIStackView!
    @IBOutlet weak var canceledByLabel: UILabel!
    @IBOutlet weak var canceledAtLabel: UILabel!
    @IBOutlet weak var canceledStackView: UIStackView!
    @IBOutlet weak var confirmedByLabel: UILabel!
    @IBOutlet weak var confirmedAtLabel: UILabel!
    @IBOutlet weak var confirmedStackView: UIStackView!
    @IBOutlet weak var deliveredByLabel: UILabel!
    @IBOutlet weak var deliveredAtLabel: UILabel!
    @IBOutlet weak var deliveredStackView: UIStackView!

    @IBOutlet weak var statusChangeButton: UIBarButtonItem!
    @IBAction func statusChangeButtonPressed(_ sender: UIBarButtonItem) {
        if order.status == Order.Status.CREATED {
            if phoneUser.isStaff {
                dbProxy.updateOrderStatus(orderId: order.id!, newStatus: .CONFIRMED, confirmedBy: phoneUser.toString())
            } else {
                askToCancel()
            }
        }
        else if order.status == Order.Status.CONFIRMED {
            dbProxy.updateOrderStatus(orderId: order.id!, newStatus: .DELIVERED, deliveredBy: phoneUser.toString())
        }
    }

    func askToCancel() {
        let cancelAlert = UIAlertController(title: .cancel.localizedUppercase, message: .confirm, preferredStyle: UIAlertController.Style.alert)
        cancelAlert.addAction(UIAlertAction(title: .yes, style: .destructive, handler: { (action: UIAlertAction!) in
            dbProxy.updateOrderStatus(orderId: self.order.id!, newStatus: .CANCELED, canceledBy: phoneUser.toString())
        }))
        cancelAlert.addAction(UIAlertAction(title: .no, style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(cancelAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.backgroundColor = .BBcellColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .BBseparatorColor
        tableView.allowsSelection = false

        categoryImage.image = UIImage(named: order.category.rawValue)
        if order.category == .Buggy, let buggyData = order.buggyData {
            buggyDataView.isHidden = false
            tableView.isHidden = true
            buggyCommentLabel.text = order.guestComment
            buggyLocationTypeLabel.text = buggyData.locationType.toString()
            buggyLocationImage.image = nil
            buggyLocationImage.isHidden = true
            buggyMapView.isHidden = true
            switch buggyData.locationType {
            case .Room: break
            case .GPS:
                //if let coordinates = order.buggyData?.locationData.split(separator: ","), coordinates.count == 2 {
                //let coo = order.buggyData?.locationData.components(separatedBy: [",", " "])
                if let coordinates = order.buggyData?.locationData.components(separatedBy: [",", " "]), coordinates.count == 2 {
                    let latitude = Double(coordinates[0]) ?? 0.0
                    let longitude = Double(coordinates[1]) ?? 0.0
                    setupMap(mapView: buggyMapView, latitude: latitude, longitude: longitude)
                    buggyMapView.isHidden = false
                }
            case .Photo:
                if let url = URL(string: buggyData.locationData) {
                    buggyLocationImage.kf.setImage(with: url)
                    buggyLocationImage.isHidden = false
                }
            case .Other: break
            }
        } else {
            buggyDataView.isHidden = true
            tableView.isHidden = false
        }

        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)

        let barButton = createBarButtonItem(target: self, action: #selector(statusChangeButtonPressed))
        statusChangeButton = barButton
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        setupListNavigationBar(largeTitle: false)

        tableView.contentInsetAdjustmentBehavior = .never

        title = .order +  " " + "\(order.number)"
        roomNumberLabel.text = .room + ": \(order.roomNumber)"
        timeCreatedLabel.text = order.created?.formatForDisplay()
        idLabel.text = .order + ": \(order.id!)"

        updateStatusLabelsAndButtons()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if order.guestComment?.isEmpty ?? true {
            return 1
        }
        return Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
            case .Items:
                return order.items.count
            case .GuestComment:
                return 1
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .Items:
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! OrderSummaryItemCell
            cell.draw(item: order.items[indexPath.row], category: order.category)
            return cell
        case .GuestComment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.textLabel?.text = order.guestComment
            return cell
            default:
                return UITableViewCell()
        }
    }

    func updateStatusLabelsAndButtons() {
        statusLabel.text = order.status.toString()
        createdStackView.isHidden = true
        confirmedStackView.isHidden = true
        deliveredStackView.isHidden = true
        canceledStackView.isHidden = true
        if phoneUser.isStaff {
            createdStackView.isHidden = false
            switch order.status {
                case .CANCELED:
                    canceledAtLabel.text = order.canceled?.formatForDisplay()
                    canceledByLabel.text = order.canceledBy
                    canceledStackView.isHidden = false
                    createdAtLabel.text = order.created?.formatForDisplay()
                    createdByLabel.text = order.createdBy
                case .DELIVERED:
                    deliveredAtLabel.text = order.delivered?.formatForDisplay()
                    deliveredByLabel.text = order.deliveredBy
                    deliveredStackView.isHidden = false
                    fallthrough
                case .CONFIRMED:
                    confirmedAtLabel.text = order.confirmed?.formatForDisplay()
                    confirmedByLabel.text = order.confirmedBy
                    confirmedStackView.isHidden = false
                    fallthrough
                case .CREATED:
                    createdAtLabel.text = order.created?.formatForDisplay()
                    createdByLabel.text = order.createdBy
                }
        }

        switch order.status {
        case .CANCELED:
            statusLabel.textColor = .black
        case .DELIVERED:
            statusLabel.textColor = .darkGreen
        case .CONFIRMED:
            statusLabel.textColor = .darkYellow
        case .CREATED:
            statusLabel.textColor = .red
        }

        let button = statusChangeButton.customView as! UIButton
        if phoneUser.isStaff {
            button.isHidden = false
            if order.status == Order.Status.CREATED {
                button.setTitle(.confirm, for: .normal)
            }
            else if order.status == Order.Status.CONFIRMED {
                button.setTitle(.finish, for: .normal)
            } else {
                button.isHidden = true
                button.setTitle("", for: .normal)
            }
        }
        else {
            let title: String = order.status == Order.Status.CREATED ? .cancel : ""
            button.setTitle(title, for: .normal)
            button.isHidden = order.status != Order.Status.CREATED
        }
    }
    
    @objc func onOrdersUpdated(_ notification: Notification) {
        if let or = phoneUser.orders.first(where: { $0.id == order.id }) {
            order = or
        }
        DispatchQueue.main.async { self.updateStatusLabelsAndButtons() }
    }

}

extension OrderSummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .GuestComment:
            if let comment = order.guestComment, !comment.isEmpty { return .comment }
            return nil
            default: return nil
        }
    }
}

extension OrderSummaryViewController {
    func setupMap(mapView:MKMapView, latitude: Double, longitude: Double) {
        mapView.layer.cornerRadius = 20.0
        mapView.clipsToBounds = true

        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        guard CLLocationCoordinate2DIsValid(coordinate) else {
            Log.log(level: .ERROR, "Invalid coordinates")
            return }
        
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


class OrderSummaryItemCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func draw(item: Order.OrderItem, category: Order.Category) {
        //if let lang = Locale.current.languageCode, let itemList = String.roomItemsList[lang], category == .RoomItems {
        if let itemList = String.roomItemsList[phoneUser.lang], category == .RoomItems {
            itemLabel.text = itemList[item.name]
        } else {
            itemLabel.text = item.name
        }
        priceLabel.text = item.price > 0.0 ? String(format: "$%.02f", item.price) : ""
        countLabel.text = String(item.quantity)
    }
}
