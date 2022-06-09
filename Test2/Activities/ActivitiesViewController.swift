//
//  ActivitiesViewController.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import UIKit

class ActivitiesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newActivityBarButton: UIBarButtonItem!

    var dowIndex: Int = 0
    var expandedCells: Set<Int> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onActivitiesUpdated(_:)), name: .activitiesUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar()
        //tabBarController?.tabBar.isHidden = true
        title = Calendar.current.weekdaySymbols[dowIndex]
        newActivityBarButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        newActivityBarButton.title = phoneUser.isAllowed(to: .editContent) ? "New" : ""
    }

    func resetDay(forward: Bool) {
        //title = Activity.DOW.allCases[dowIndex].rawValue
        title = Calendar.current.weekdaySymbols[dowIndex]

        var oldPaths = [IndexPath]()
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            oldPaths.append(indexPath)
        }
        var newPaths = [IndexPath]()
        if let count = hotel.activities[dowIndex]?.count {
            for row in 0..<count {
                let indexPath = IndexPath(row: row, section: 0)
                newPaths.append(indexPath)
            }
        }

        tableView.beginUpdates()
        tableView.deleteRows(at: oldPaths, with: forward ? .left : .right)
        tableView.insertRows(at: newPaths, with: forward ? .right : .left)
        //tableView.reloadRows(at: rows, with: forward ? .left : .right)
        tableView.endUpdates()
        tableView.layoutIfNeeded()
 
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
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([0], with: .none)
            self.tableView.setNeedsLayout()
            self.tableView.endUpdates()
        }
    }

    @IBAction func newActivityPressed(_ sender: Any) {
        let vc = self.createViewController(storyBoard: "Activities", id: "NewActivity") as! NewActivityViewController
        vc.dowIndex = dowIndex
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ActivitiesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotel.activities[dowIndex]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        if let activity = hotel.activities[dowIndex]?[indexPath.row] {
            let expanded = expandedCells.contains(activity.hashValue)
            cell.draw(activity: activity, expanded: expanded)
        }
        return cell
    }

}

extension ActivitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityCell else { return }
        if let activity = hotel.activities[dowIndex]?[indexPath.row] {
            if expandedCells.contains(activity.hashValue) { expandedCells.remove(activity.hashValue) }
            else { expandedCells.insert(activity.hashValue) }
            tableView.beginUpdates()
            cell.draw(activity: activity, expanded: expandedCells.contains(activity.hashValue))
            tableView.endUpdates()
            //tableView.layoutIfNeeded()    // causes jerkiness on Mac app
            tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .normal, title: "Edit") { action, view, completionHandler in
            self.openNewActivityViewController(row: indexPath.row)
            completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            if let activity = hotel.activities[self.dowIndex]?[indexPath.row] {
                _ = dbProxy.removeRecord(key: activity.id!, subNode: self.title, record: activity) { _ in
                }
            }
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func openNewActivityViewController(row: Int) {
        if let vc = createViewController(storyBoard: "Activities", id: "NewActivity") as? NewActivityViewController {
            vc.activityToEdit = hotel.activities[dowIndex]?[row]
            vc.dowIndex = dowIndex
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
