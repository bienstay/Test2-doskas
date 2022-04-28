//
//  AssignViewController.swift
//  Test2
//
//  Created by maciulek on 27/04/2022.
//

import UIKit

struct UserData {
    var email: String
    var displayName: String
    var role: PhoneUser.Role
    var id: String { email.components(separatedBy: "@")[0] }
}

class AssignViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var users: [UserData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        initUserList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false)
        title = "Assign to"
    }

    func initUserList() {
        dbProxy.getUsers(hotelName: hotel.id ?? "") { userList in
            for u in userList {
                if let e = u["email"], let d = u["displayName"], let r = u["role"] {
                    self.users.append(UserData(email: e, displayName: d, role: .init(rawValue: r) ?? .none))
                }
            }
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].email
        cell.detailTextLabel?.text = users[indexPath.row].role.rawValue
        return cell
    }
    
}
