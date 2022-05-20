//
//  MenuView.swift
//  Test2
//
//  Created by maciulek on 05/05/2022.
//

import UIKit

class MenuView: UIView {
    typealias MenuCallback = () -> Void
    var leftConstraint: NSLayoutConstraint!
    var tableView: UITableView!
    typealias Items = [(String, MenuCallback)]
    var items: Items = []
    var sections: [Items] = [Items()]
    var isOn: Bool = false
    let width = 200.0
    var currentSection = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubViews(headerText: "")
    }

    required init? (coder: NSCoder) {
        super.init(coder: coder)
        createSubViews(headerText: "")
    }

    init(parentView: UIView, headerText: String) {
        super.init(frame: CGRect.zero)
        parentView.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        topAnchor.constraint(equalTo: superview!.topAnchor, constant: 90).isActive = true
        //bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: -300).isActive = true
        leftConstraint = leftAnchor.constraint(equalTo: superview!.leftAnchor, constant: 0)
        leftConstraint.constant = -width
        leftConstraint.isActive = true
        backgroundColor = .BBbackgroundColor

        layer.masksToBounds = false
        layer.cornerRadius = 20
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.black.cgColor
        createSubViews(headerText: headerText)
    }

    func present(show: Bool) {
        leftConstraint.constant = show ? 0 : -width
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseIn]) {
            self.superview!.layoutIfNeeded()
        }
        isOn = show
    }

    // TODO - detect a touch outside of the menu
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != self {
            toggle()
        }
    }


    func toggle() {
        present(show: !isOn)
    }

    func addSeparator() {
        sections.append(Items())
        currentSection += 1
    }

    func addItem(label: String, callback: @escaping MenuCallback) {
        //items.append((label, callback))
        sections[currentSection].append((label, callback))
        tableView.reloadData()
    }

    // Creating subview
    private func createSubViews(headerText: String) {
        //tableView = UITableView()
        tableView = ContentWrappingTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "menuCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .BBbackgroundColor

        //tableView.estimatedRowHeight = 50
        //tableView.rowHeight = UITableView.automaticDimension
/*
        let header: UIView?
        if let image = UIImage(named: "logoAppviator3dWithLetters") {
            let image = UIImageView(image: image)
            header = image
        }
        */
        let image = UIImageView(image: UIImage(named: "logoAppviator3dWithLetters"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        let version = UILabel()
        version.text = "ver 0.1"
        version.textAlignment = .right
        version.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption2)
        let info = UILabel()
        info.numberOfLines = 0
        info.text = phoneUser.displayName + "  " + (phoneUser.role?.rawValue ?? "")
        info.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.addArrangedSubview(info)
        stackView.addArrangedSubview(image)
        stackView.addArrangedSubview(version)
        stackView.addArrangedSubview(tableView)

        addSubview(stackView)

        NSLayoutConstraint.activate([
        //    header.heightAnchor.constraint(equalToConstant: 150),
        //    header.widthAnchor.constraint(equalToConstant: 150),
        image.widthAnchor.constraint(equalTo: image.heightAnchor, constant: 1),
        stackView.topAnchor.constraint(equalTo:topAnchor, constant: 10),
        stackView.leftAnchor.constraint(equalTo:leftAnchor, constant: 10),
        stackView.rightAnchor.constraint(equalTo:rightAnchor, constant: -10),
        stackView.bottomAnchor.constraint(equalTo:bottomAnchor, constant: -10)
        ])
        
        layoutSubviews()
    }
}

extension MenuView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.text = sections[indexPath.section][indexPath.row].0
        cell.backgroundColor = .BBbackgroundColor
        return cell
    }
}

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section][indexPath.row].1()
        present(show: false)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return nil }
        return " "
    }
}



class ContentWrappingTableView: UITableView {

    override var intrinsicContentSize: CGSize {
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
}
