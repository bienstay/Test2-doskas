//
//  AssignViewController.swift
//  Test2
//
//  Created by maciulek on 27/04/2022.
//

import UIKit

class AssignViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var users: [AuthenticationData] = []
    var chatRoom: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        initUserList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false)
        title = "Assign to"
    }

    func initUserList() {
        authProxy.getUsers(hotelName: hotel.id.lowercased()) { [weak self] userList in
            self?.users = userList
/*
            for u in userList {
                if let e = u["email"], let r = u["role"], let uid = u["uid"] {
                    self.users.append(UserData(email: e, role: .init(rawValue: r) ?? .none, uid: uid))
                }
            }
*/
            DispatchQueue.main.async { self?.tableView.reloadData() }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignCell", for: indexPath) as! AssignCell
        cell.draw(userData: users[indexPath.row])
        //cell.textLabel?.text = users[indexPath.row].id
        //cell.detailTextLabel?.text = users[indexPath.row].role.rawValue
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dbProxy.assignChat(chatRoom: chatRoom, to: users[indexPath.row].name)
        if let nc = navigationController {
            nc.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}

class AssignCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userRoleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func draw(userData: AuthenticationData) {
        userNameLabel.text = userData.name
        userRoleLabel.text = userData.role?.rawValue
    }
}
