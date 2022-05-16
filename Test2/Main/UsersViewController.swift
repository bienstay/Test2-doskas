//
//  UsersViewController.swift
//  Test2
//
//  Created by maciulek on 14/05/2022.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var newBarButton: UIBarButtonItem!
    @IBOutlet weak var newButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var users: [AuthenticationData] = []

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
        newBarButton.isEnabled = phoneUser.isStaff
        newBarButton.title = phoneUser.isStaff ? "New" : ""
        initUserList()
    }

    @IBAction func newButtonPressed(_ sender: Any) {
        //_ = self.pushViewController(storyBoard: "Main", id: "AddUser")
        show(createViewController(storyBoard: "Main", id: "AddUser"), sender: self)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let name = users[indexPath.row].name
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = users[indexPath.row].role?.rawValue
        return cell
    }

    func initUserList() {
        users = []
        authProxy.getUsers(hotelName: hotel.id) { [weak self] userList in
            self?.users = userList
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
    }
}

extension UsersViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Edit") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            //let vc = self.pushViewController(storyBoard: "Main", id: "EditUser") as! EditUserViewController
            let vc = self.createViewController(storyBoard: "Main", id: "EditUser") as! EditUserViewController
            vc.user = self.users[indexPath.row]
            self.show(vc, sender: self)
            completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            let uid = self.users[indexPath.row].uid
            let name = self.users[indexPath.row].name
            authProxy.deleteUser(uid: uid) { [weak self] (error) in
                if let error = error {
                    self?.showInfoDialogBox(title: "Error", message: "Error deleting the user with id \(uid)\n\(error)")
                } else {
                    self?.showInfoDialogBox(title: "Success", message: "User \(name) deleted")
                }
                self?.initUserList()
            }
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

}
