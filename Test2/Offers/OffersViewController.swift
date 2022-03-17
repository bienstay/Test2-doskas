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

    @IBAction func newOfferGroupPressed(_ sender: Any) {
    }
}

extension OffersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotel.offerGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OffersCell", for: indexPath) as! OffersCell
        cell.configure(group: indexPath.row, title: hotel.offerGroups[indexPath.row].title, subTitle: hotel.offerGroups[indexPath.row].subTitle, dataSource: self) { offerIndex in
            print("selected offer \(offerIndex) in group \(indexPath.row) ")
            let vc = self.pushViewController(storyBoard: "Offers", id: "Offer") as! OfferViewController
            //vc.offer = hotel.offerGroups[indexPath.row].offers![offerIndex]
            if let offerID = hotel.offerGroups[indexPath.row].offers?[offerIndex] {
                vc.offer = hotel.offers[offerID] ?? Offer()
            }
        }
        cell.cellSelectedForEditClosure = { offerIndex in
            print("selected offer \(offerIndex) in group \(indexPath.row) ")
            let vc = self.pushViewController(storyBoard: "Offers", id: "NewOffer") as! NewOfferViewController
            if let offerID = hotel.offerGroups[indexPath.row].offers?[offerIndex] {
                vc.offerToEdit = hotel.offers[offerID] ?? Offer()
            }
        }
/*
        let vc = self.createViewController(storyBoard: "News", id: "NewPost") as! NewNewsPostViewController
        vc.postToEdit = hotel.news[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
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
            cell.cellSelectedForEditClosure = { offer in
                let vc = self.createViewController(storyBoard: "Offers", id: "NewOffer") as! NewOfferViewController
                vc.offerToEdit = offer
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }

}
