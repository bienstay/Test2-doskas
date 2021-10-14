//
//  Home1ViewController.swift
//  Test2
//
//  Created by maciulek on 15/05/2021.
//

import UIKit
import Kingfisher


class HomeViewController: UIViewController {
    private enum Section: Int, CaseIterable {
        case importantNote
        case info
        case news
        //case map
        //case coralPropagation
        //case generalInfo
        //case todayActivities
        static var numberOfSections: Int { return self.allCases.count }
    }
    var onboardingShown: Bool = false

    @IBOutlet var tableView: UITableView!
    @IBOutlet var hotelNameLabel: UILabel!
    @IBOutlet var hotelImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never   // hides the navigation bar
        tableView.separatorStyle = .singleLine

        NotificationCenter.default.addObserver(self, selector: #selector(onHotelInfoUpdated(_:)), name: .hotelInfoUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNewsUpdated(_:)), name: .newsUpdated, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTapsRequired = 3
        hotelNameLabel.addGestureRecognizer(tap)
        hotelNameLabel.isUserInteractionEnabled = true
    }

    func displayHeader() {
        hotelNameLabel.text = hotel.name
        hotelImageView.kf.setImage(with: URL(string: hotel.image))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        displayHeader()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        if !onboardingShown {
            let vc = OnboardingPageViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            onboardingShown = true
        }
    }

    @objc func onHotelInfoUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.displayHeader()
        }
    }

    @objc func onNewsUpdated(_ notification: Notification) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    @objc func didTap(sender: UITapGestureRecognizer) {
        ConfigViewController.showPopup(parentVC: self)
    }
}


// MARK: Data Source
extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .importantNote: return 1
        case .info: return 3    // TODO, right now maps, sports, coral
        case .news:
            if hotel.news.count >= 2 { return 3 }
            else if hotel.news.count == 1 { return 2 }
            else { return 0 }
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .importantNote: return "Important note"
        case .info: return "Hotel information"
        case .news: return "Latest resort news"
        default: return "Section \(section)"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .importantNote:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImportantCell", for: indexPath) as! Cell2HomeTableViewCell
            cell.note.text = "COVID-19 updates and what to expect at our hotel"
            return cell
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! HomeInfoCell
            if indexPath.row == 0 { cell.note.text = "Map" }
            else if indexPath.row == 1 { cell.note.text = "Adopt a coral" }
            else if indexPath.row == 2 { cell.note.text = "Water activities" }
            return cell
        case .news:
            if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MoreNewsCell", for: indexPath)
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            cell.draw(post: hotel.news[indexPath.row])
            return cell
        default:
            return UITableViewCell()
        }
    }
}


// MARK: Delegate
extension HomeViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .info:
            if indexPath.row == 0 {
                _ = pushViewController(storyBoard: "Map", id: "mapViewController")
                //_ = pushViewController(storyBoard: "Activities", id: "Activities")

                //                let vc = OnboardingPageViewController()
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)

//                let vc = MessageKitChatViewController()
//                navigationController?.pushViewController(vc, animated: true)
//                _ = pushViewController(storyBoard: "Chat", id: "ChatList")
            } else
            if indexPath.row == 1 {
                let vc = pushOrPresent(storyBoard: "Info", id: "Info") as! InfoViewController
                vc.infoItem = hotel.infoItems[0]    // TODO
            }
            if indexPath.row == 2 {
                //_ = pushViewController(storyBoard: "WaterSports", id: "WaterSports")
                _ = pushViewController(storyBoard: "Home", id: "HomeCollectionViewController")
            }
        case .news:
            if indexPath.row < 2 {
                let vc = pushOrPresent(storyBoard: "News", id: "NewsDetail") as! NewsDetailViewController
                vc.post = hotel.news[indexPath.row]
            } else {    // More...
                _ = pushOrPresent(storyBoard: "News", id: "News")
            }
        default: break
        }
    }
}




// important note
class Cell2HomeTableViewCell: UITableViewCell {
    @IBOutlet var picture: UIImageView!
    @IBOutlet var note: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        layer.masksToBounds = false
        picture.layer.cornerRadius = 5
    }
}

class MoreNewsCell: UITableViewCell {
    @IBOutlet var note: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        //note.font = UIFont(name: note.font.fontName, size: 20)
        note.text = "More news..."
    }
}

class HomeInfoCell: UITableViewCell {
    @IBOutlet var picture: UIImageView!
    @IBOutlet var note: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        layer.masksToBounds = false
        picture.layer.cornerRadius = 5
    }
}

