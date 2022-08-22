//
//  MenuListViewController.swift
//  Test2
//
//  Created by maciulek on 10/07/2022.
//

import UIKit

class MenuListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var menuPickerView: UIPickerView!

    var restaurant: Restaurant = Restaurant()
    var completionCallback: (([String]) -> Void)?
    var allMenus: [String] = []
    var selectedMenus: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dragInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        menuPickerView.dataSource = self
        menuPickerView.delegate = self
        tableView.layer.borderWidth = 1
        menuPickerView.layer.borderWidth = 1

        selectedMenus = restaurant.menus
        allMenus = hotel.menus.keys.sorted()
        allMenus = allMenus.filter{ !selectedMenus.contains($0) }.sorted()

        view.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(tintColor: nil, largeTitle: false, title: restaurant.name)
        
        navigationItem.title = "Menu List"
    }

    @IBAction func minusButtonPressed(_ sender: UIButton) {
        if let sel = tableView.indexPathForSelectedRow?.row {
            let menu = selectedMenus[sel]
            selectedMenus.remove(at: sel)
            allMenus.append(menu)
            tableView.reloadData()
            menuPickerView.reloadAllComponents()
        }
    }

    @IBAction func plusButtonPressed(_ sender: UIButton) {
        guard !allMenus.isEmpty else { return }
        let sel = menuPickerView.selectedRow(inComponent: 0)
        let menu = allMenus.remove(at: sel)
        selectedMenus.append(menu)
        tableView.reloadData()
        menuPickerView.reloadAllComponents()
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
//        dbProxy.writeMenuList(restaurantId: restaurant.id, menuList: selectedMenus) { [weak self] in
//            print("menu list written")
//            guard let self = self else { return }
//            self.completionCallback?(self.selectedMenus)
//            self.navigationController?.popViewController(animated: true)
//        }
        self.completionCallback?(self.selectedMenus)
        self.navigationController?.popViewController(animated: true)
    }
}

extension MenuListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedMenus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuCell {
            cell.draw(name: selectedMenus[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
}

extension MenuListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allMenus.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        allMenus[row]
    }
}

extension MenuListViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // return [] // return [] won't stop the table view from draging. However, Apple wants us to do it on our own.
        
        return [UIDragItem(itemProvider: NSItemProvider(object: selectedMenus[indexPath.row] as NSItemProviderWriting))]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else { return }
        let item = selectedMenus[sourceIndexPath.row]
        if sourceIndexPath.row < destinationIndexPath.row {
            selectedMenus.insert(item, at: destinationIndexPath.row + 1)
            selectedMenus.remove(at: sourceIndexPath.row)
        } else {
            selectedMenus.remove(at: sourceIndexPath.row)
            selectedMenus.insert(item, at: destinationIndexPath.row)
        }
    }
}

class MenuCell: UITableViewCell {
    @IBOutlet private weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .blue
    }

    func draw(name: String) {
        nameLabel.text = name
    }
}
