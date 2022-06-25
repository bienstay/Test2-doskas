//
//  TestViewController.swift
//  Test2
//
//  Created by maciulek on 19/06/2022.
//

import UIKit

struct Source {
    let title: String
    let subtitle: String
}

class TestViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var source = [Source]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .offWhiteVeryLight
        tableView.backgroundColor = .none
        navigationController?.navigationBar.prefersLargeTitles = true
        self.source = Array(0...99).compactMap({
            Source(title: "title \($0)", subtitle: "subtitle \($0)")
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //setupListNavigationBar()
        title = "Test"
    }

    override func viewWillDisappear(_ animated: Bool) {
        title = ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Int(source.count / 20)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "section \(section)"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(source.count / 20)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTestCell", for: indexPath)
        let s = source[indexPath.row]
        cell.textLabel?.text = s.title
        cell.detailTextLabel?.text = s.subtitle
        return cell
        */
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestCell
        let s = source[indexPath.row]
        cell.draw(source: s)
        return cell
    }
}

extension TestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}









class TestCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
        imageContainerView.layer.cornerRadius = 8
        imageContainerView.layer.masksToBounds = true
    }

    func draw(source: Source) {
        titleLabel.text = source.title
        imageContainerView.backgroundColor = [.systemPink, .systemBlue, .systemGreen, .systemOrange].randomElement()
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: "airplane")
        } else {
            // Fallback on earlier versions
        }
    }
}
