//
//  TestViewController.swift
//  Test2
//
//  Created by maciulek on 04/05/2021.
//

import UIKit



class TestTableViewCell2: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cuisineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var enlargedStackView: UIStackView!
    @IBOutlet weak var largeIcon: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .offWhite
        contentView.backgroundColor = .offWhite
        icon.layer.cornerRadius = icon.bounds.height/2
    }
}






class TestTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    lazy var menus = (hotel.facilities[.Restaurant]!["Masala Hut"] as! Restaurant).menus

    struct DisplayData {
        var expanded: Bool = false
        var nrOrdered: Int = 0
    }

    lazy var dd = Array(repeating: Array(repeating: DisplayData(), count: 100), count: menus[3].sections.count)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!

    func numberOfSections(in tableView: UITableView) -> Int {
        //return 3
        return menus[3].sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return source.count
        return menus[3].sections[section].items.count
    }


    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! TestTableViewCell2

        let menuItem = menus[3].sections[indexPath.section].items[indexPath.row]
        if menuItem.itemType == MenuItem.FOODITEM {
            cell.titleLabel.text = menuItem.title
            cell.priceLabel.text = "$\(menuItem.price)"
            cell.descriptionLabel.text = menuItem.description
            cell.cuisineLabel.text = menuItem.attributes.joined(separator: " ")
            cell.icon.isHidden = dd[indexPath.section][indexPath.row].expanded
            cell.enlargedStackView.isHidden = !dd[indexPath.section][indexPath.row].expanded
            cell.titleLabel.textColor = .black
            return cell;
        } else {
            cell.titleLabel.text = menuItem.title
            cell.priceLabel.text = ""
            cell.descriptionLabel.text = ""
            cell.cuisineLabel.text = ""
            cell.icon.isHidden = true
            cell.enlargedStackView.isHidden = true
            cell.titleLabel.textColor = .orange
            return cell
        }
    }

/*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! TestTableViewCell2
        cell.descriptionLabel.text = source[indexPath.row].s

        if self.source[indexPath.row].enlarged {
            cell.enlargedStackView.isHidden = false
            cell.icon.isHidden = true
        } else {
            cell.enlargedStackView.isHidden = true
            cell.icon.isHidden = false
        }

        return cell
    }
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        tableView.backgroundColor = .offWhite

        self.tabBarController?.tabBar.backgroundColor = .darkGray

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = true
        tableView.isEditing = false

        // below is needed for the separator to go edge-to-edge
        //tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero

        title = "Masala Hut Lunch"
        headerLabel.text = menus[3].title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .clear
        
        let nib = UINib(nibName: "TestSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "HeaderTableView")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //source[indexPath.row].enlarged.toggle()
        dd[indexPath.section][indexPath.row].expanded.toggle()
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}






class TestSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .offWhite
        contentView.backgroundColor = .offWhite
        sectionHeaderLabel.textColor = .orange
    }

}

class TestSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .offWhite
        contentView.backgroundColor = .offWhite
        sectionHeaderLabel.textColor = .gray
    }

}

extension TestTableViewController {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderTableView") as! TestSectionHeaderView
        view.sectionHeaderLabel.text = menus[3].sections[section].title
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
      }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
      }
}

