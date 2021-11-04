//
//  OrdersViewController.swift
//  Test2
//
//  Created by maciulek on 04/06/2021.
//

import UIKit

class OrdersViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activeOrdersSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UIBarButtonItem!
    var showActiveOnly: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)
        activeOrdersSwitchClicked(activeOrdersSwitch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
/*
        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
*/
        tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showActiveOnly { return guest.activeOrders.count }
        else { return guest.orders.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderDetailsCell
        if showActiveOnly { cell.draw(order: guest.activeOrders[indexPath.row]) }
        else { cell.draw(order: guest.orders[indexPath.row]) }
        return cell
    }

    @objc func onOrdersUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            //prepareNotification(id: "order", title: "ORDERS", subtitle: "", body: "Orders have been updated", attachmentFile: "roomOrder")
        }
    }
    
    @IBAction func activeOrdersSwitchClicked(_ sender: UISwitch) {
        showActiveOnly = !sender.isOn
        switchLabel.title = sender.isOn ? "All" : "Active"
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

extension OrdersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = pushOrPresent(storyBoard: "OrderSummary", id: "OrderSummary") as! OrderSummaryViewController
        vc.order = showActiveOnly ? guest.activeOrders[indexPath.row] : guest.orders[indexPath.row]
    }
}
