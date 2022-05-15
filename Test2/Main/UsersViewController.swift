//
//  UsersViewController.swift
//  Test2
//
//  Created by maciulek on 14/05/2022.
//

import UIKit

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var newButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var users: [UserData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        //initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(largeTitle: false, title: "Users")
        newButton.isEnabled = phoneUser.isStaff
        newButton.title = phoneUser.isStaff ? "New" : ""
        initUserList()
    }

    @IBAction func newButtonPressed(_ sender: Any) {
        _ = self.pushViewController(storyBoard: "Main", id: "AddUser")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let name = String(users[indexPath.row].email.split(separator: "@")[0])
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = users[indexPath.row].role.rawValue
        return cell
    }

    func initUserList() {
        users = []
        dbProxy.getUsers(hotelName: hotel.id) { [weak self] userList in
            for u in userList {
                if let e = u["email"], let r = u["role"], let uid = u["uid"] {
                    self?.users.append(UserData(email: e, role: .init(rawValue: r) ?? .none, uid: uid))
                }
            }
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
    }
}

extension UsersViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Edit") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            let vc = self.pushViewController(storyBoard: "Main", id: "EditUser") as! EditUserViewController
            vc.userName = self.users[indexPath.row].displayName
            // edit a user
            //let vc = self.createViewController(storyBoard: "News", id: "NewPost") as! NewNewsPostViewController
            //vc.postToEdit = hotel.news[indexPath.row]
            //self.navigationController?.pushViewController(vc, animated: true)
            //completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            let uid = self.users[indexPath.row].uid
            let name = self.users[indexPath.row].displayName
            dbProxy.deleteUser(uid: uid) { [weak self] (error) in
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
