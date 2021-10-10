//
//  ActivitiesViewController.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import UIKit
import FirebaseDatabase

class ActivitiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPostBarButton: UIBarButtonItem!

    var dowIndex: Int = 0
    var expandedCells: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onActivitiesUpdated(_:)), name: .activitiesUpdated, object: nil)
        title = Activity.DOW.allCases[dowIndex].rawValue
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        
        title = Activity.DOW.allCases[dowIndex].rawValue
    }

    func resetDay(forward: Bool) {
        title = Activity.DOW.allCases[dowIndex].rawValue

        var oldPaths = [IndexPath]()
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            oldPaths.append(indexPath)
        }
        var newPaths = [IndexPath]()
        if let count = hotel.activities[title!]?.count {
            for row in 0..<count {
                let indexPath = IndexPath(row: row, section: 0)
                newPaths.append(indexPath)
            }
        }

        //UIView.transition(with: tableView, duration: 3.0, options: [.layoutSubviews, .transitionCrossDissolve], animations: {self.tableView.reloadData()}, completion: nil)
        //tableView.reloadSections([0], with: .left)

        tableView.beginUpdates()
        tableView.deleteRows(at: oldPaths, with: forward ? .left : .right)
        tableView.insertRows(at: newPaths, with: forward ? .right : .left)
        //tableView.reloadRows(at: rows, with: forward ? .left : .right)
        tableView.endUpdates()
        //tableView.layoutIfNeeded()
 
        expandedCells = []
    }

    @IBAction func forwardPressed(_ sender: UIBarButtonItem) {
        dowIndex += 1
        if dowIndex >= Activity.DOW.allCases.count { dowIndex = 0 }
        resetDay(forward: true)
    }
    
    @IBAction func backwardsPressed(_ sender: UIBarButtonItem) {
        dowIndex -= 1
        if dowIndex < 0 { dowIndex = Activity.DOW.allCases.count - 1 }
        resetDay(forward: false)
    }

    @objc func onActivitiesUpdated(_ notification: Notification) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    @IBAction func newActivityPressed(_ sender: Any) {
        let vc = self.createViewController(storyBoard: "Activities", id: "NewActivity") as! NewActivityViewController
        vc.dowIndex = dowIndex
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ActivitiesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotel.activities[title!]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        if let activity = hotel.activities[title!]?[indexPath.row] {
            let expanded = expandedCells.contains(activity.hashValue)
            cell.draw(activity: activity, expanded: expanded)
        }
        return cell
    }

}

extension ActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityCell else { return }
        if let activity = hotel.activities[title!]?[indexPath.row] {
            if expandedCells.contains(activity.hashValue) { expandedCells.remove(activity.hashValue) }
            else { expandedCells.insert(activity.hashValue) }
            tableView.beginUpdates()
            cell.draw(activity: activity, expanded: expandedCells.contains(activity.hashValue))
            tableView.endUpdates()
            tableView.layoutIfNeeded()
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let vc = self.createViewController(storyBoard: "Activities", id: "NewActivity") as! NewActivityViewController
        vc.activityIndexToEdit = indexPath.row
        vc.dowIndex = dowIndex
        self.navigationController?.pushViewController(vc, animated: true)
        return nil
    }
}
