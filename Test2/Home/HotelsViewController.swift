//
//  HotelsViewController.swift
//  Test2
//
//  Created by maciulek on 16/06/2022.
//

import UIKit

class HotelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var newBarButton: UIBarButtonItem!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var hotels: [(key:String, value:String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        newButton.isHidden = navigationController != nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(largeTitle: false, title: "Users")
        newBarButton.isEnabled = phoneUser.isAllowed(to: .manageHotels)
        newBarButton.title = phoneUser.isAllowed(to: .manageHotels) ? "New" : ""
        initHotelList()
    }

    @IBAction func newButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new hotel", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in textField.placeholder = "hotelid" }
        alert.addTextField { (textField) in textField.placeholder = "Hotel Name" }

        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields?[0], let hotelId = textField.text else { return }
            guard let textField = alert?.textFields?[1], let hotelName = textField.text else { return }
            dbProxy.addHotel(hotelId: hotelId, hotelName: hotelName) { [weak self] error in
                if let error = error {
                    self?.showInfoDialogBox(title: "Error", message: "Error adding hotel: \(error)")
                } else {
                    self?.showInfoDialogBox(title: "Hotel added", message: "Hotel: \(hotelId)\n\(hotelName)") { [weak self] _ in
                        self?.initHotelList()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))

        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HotelCell", for: indexPath) as! HotelCell
        cell.draw(id: hotels[indexPath.row].key, name: hotels[indexPath.row].value)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func initHotelList() {
        hotels = []
        dbProxy.getHotelList() { [weak self] hotelList in
            self?.hotels = hotelList.sorted(by: { $0.key < $1.key })
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
    }
}

extension HotelsViewController {

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            let key = self.hotels[indexPath.row].key
            dbProxy.removeRecord(path: "config/hotels/", key: key) { [weak self] (error) in
                if let error = error {
                    self?.showInfoDialogBox(title: "Error", message: "Error deleting hotel  \(key)\n\(error)")
                } else {
                    self?.showInfoDialogBox(title: "Success", message: "Hotel \(key) deleted")
                }
                self?.initHotelList()
            }
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

}


class HotelCell: UITableViewCell {
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func draw(id: String, name: String) {
        idLabel.text = id
        nameLabel.text = name
    }
}
