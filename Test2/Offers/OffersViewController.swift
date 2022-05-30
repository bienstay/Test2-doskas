//
//  OffersViewController.swift
//  Test2
//
//  Created by maciulek on 20/11/2021.
//

import UIKit

class OffersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newOfferGroupButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onOffersUpdated(_:)), name: .offersUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false)

        title = .offers
        //newOfferGroupButton.isEnabled = guest.isAdmin() ? true: false
        //newOfferGroupButton.title = guest.isAdmin() ? "New" : ""
    }

    @objc func onOffersUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([0], with: .none)
            self.tableView.setNeedsLayout()
            self.tableView.endUpdates()
        }
    }

    @IBAction func newOfferPressed(_ sender: UIButton) {
        if let vc = pushViewController(storyBoard: "Offers", id: "NewOffer") as? NewOfferViewController {
            vc.groupIndex = sender.tag
        }
    }

    @IBAction func newOfferGroupPressed(_ sender: Any) {
        _ = pushViewController(storyBoard: "Offers", id: "NewOfferGroup")
    }
}

extension OffersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotel.offerGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffersCell", for: indexPath) as! OffersCell
        cell.configure(group: indexPath.row, title: hotel.offerGroups[indexPath.row]._title, subTitle: hotel.offerGroups[indexPath.row]._subtitle, dataSource: self) { offerIndex in
            let vc = self.pushViewController(storyBoard: "Offers", id: "Offer") as! OfferViewController
            //vc.offer = hotel.offerGroups[indexPath.row].offers![offerIndex]
            if let offerID = hotel.offerGroups[indexPath.row].offers?[offerIndex] {
                vc.offer = hotel.offers[offerID] ?? Offer()
            }
        }
        cell.newOfferButton.tag = indexPath.row
        /*
        cell.cellSelectedForEditClosure = { [weak self] offerIndex in
            guard let self = self else { return }
            if let vc = self.pushViewController(storyBoard: "Offers", id: "NewOffer") as? NewOfferViewController, let offerID = hotel.offerGroups[indexPath.row].offers?[offerIndex] {
                vc.offerToEdit = hotel.offers[offerID] ?? Offer()
            }
        }
         */
        return cell
    }

    var cellSize: Double {
        var size: Double = 300.0
        if traitCollection.horizontalSizeClass == .compact {
            size = UIScreen.main.bounds.width * 2.0 / 3.0
        }
        return size
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellSize + 60    // TODO - ugly
    }

}

extension OffersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let group = collectionView.tag
        let count: Int = hotel.offerGroups[group].offers?.count ?? 0
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OfferCell", for: indexPath) as! OfferCollectionViewCell
        let group = collectionView.tag
        //cell.configure(offer: hotel.offerGroups[group].offers?[indexPath.row])
        if let offerID = hotel.offerGroups[group].offers?[indexPath.row] {
            cell.configure(offer: hotel.offers[offerID])
            cell.cellSelectedForEditClosure = { [weak self] offer in
                guard let self = self else { return }
                let vc = self.createViewController(storyBoard: "Offers", id: "NewOffer") as! NewOfferViewController
                vc.offerToEdit = offer
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.cellSelectedForDeleteClosure = { offer in
                guard let id = offer.id else { return }
                print("delete offer \(offer)")
                _ = dbProxy.removeRecord(key: id, record: offer) { _ in }

                hotel.offerGroups[group].offers = hotel.offerGroups[group].offers?.filter { $0 != id }
                _ = dbProxy.addRecord(key: hotel.offerGroups[group].id, record: hotel.offerGroups[group]) { _, error in }
            }
        }
        return cell
    }

}

extension OffersViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .normal, title: "Edit") { action, view, completionHandler in
            if let vc = self.pushViewController(storyBoard: "Offers", id: "NewOfferGroup") as? NewOfferGroupViewController {
                vc.groupToEdit = hotel.offerGroups[indexPath.row]
            }
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.deleteOfferGroup(group: hotel.offerGroups[indexPath.row])
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func deleteOfferGroup(group: OfferGroup) {
        guard let id = group.id else { return }
        let errStr = dbProxy.removeRecord(key: id, record: group) { record in
            if record == nil {
                self.showInfoDialogBox(title: "Error", message: "Group delete failed")
            } else {
                self.showInfoDialogBox(title: "Info", message: "Offer group deleted")
            }
        }
        if errStr != nil { Log.log(errStr!) }
    }

}
