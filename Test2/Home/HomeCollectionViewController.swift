//
//  HomeCollectionViewController.swift
//  Test2
//
//  Created by maciulek on 12/10/2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!

    private enum Section: Int, CaseIterable {
        case header = 0
        case title = 1
        case items = 2
        static var numberOfSections: Int { return self.allCases.count }
    }
    private enum Items: String, CaseIterable {
        case news = "News"
        case activities = "Activities"
        case map = "Map"
        case watersports = "Water Sports"
        case adoptACoral = "Adopt a Coral"
        case kidsClub = "Kids Club"
    }
    
    let tempIconNames = ["News", "Activities", "Map", "Watersports", "AdoptAcoral", "KidsClub", "Sugar", "Soap", "022-room key", "033-bucket"]
    let tempIconColors: [UIColor] = [.color1, .color2, .color3, .lightGray, .color2, .color1, .color3]

    var onboardingShown: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .never   // hides the navigation bar

        NotificationCenter.default.addObserver(self, selector: #selector(onHotelInfoUpdated(_:)), name: .hotelInfoUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            self.collectionView.reloadSections([Section.header.rawValue, Section.title.rawValue])
        }
    }

    @objc func didTap(sender: UITapGestureRecognizer) {
        ConfigViewController.showPopup(parentVC: self)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .header: return 1
        case .title: return 1
        case .items: return Items.allCases.count
        case .none: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeHeaderCell", for: indexPath) as! HomeHeaderCell
            cell.tapClosure = { ConfigViewController.showPopup(parentVC: self) }
            cell.draw(imageURL: hotel.image)
            return cell
        case .title:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTitleCell", for: indexPath) as! HomeTitleCell
            cell.draw(title: hotel.name)
            return cell
        case .items:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeItemsCell", for: indexPath) as! HomeItemsCell
            cell.tag = indexPath.row
            cell.draw(title: Items.allCases[indexPath.row].rawValue, pictureName: tempIconNames[indexPath.row], color: tempIconColors[indexPath.row])
            return cell
        case .none:
            Log.log(level: .ERROR, "invalid section in cellForItem")
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section) {
        case .items:
            let item: Items = Items.allCases[indexPath.row]
            switch item {
            case .news:         _ = pushOrPresent(storyBoard: "News", id: "News")
            case .activities:   _ = pushViewController(storyBoard: "Activities", id: "Activities")
            case .map:          _ = pushViewController(storyBoard: "Map", id: "mapViewController")
            case .watersports:  _ = pushViewController(storyBoard: "WaterSports", id: "WaterSports")
            case .adoptACoral:
                let vc = pushOrPresent(storyBoard: "Info", id: "Info") as! InfoViewController
                vc.infoItem = hotel.infoItems[0]    // TODO
            case .kidsClub:     _ = pushViewController(storyBoard: "Activities", id: "Activities")
            }
            default: break
        }
    }

}

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    private static let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch Section(rawValue: indexPath.section) {
        case .header:
            return CGSize(width: collectionView.bounds.width, height: floor(collectionView.bounds.width*3.0/4.0))
        case .title:
            //let h = calculateLabelHeight(s: hotel.name, width: collectionView.bounds.width)
            return CGSize(width: collectionView.bounds.width, height: 80)
        case .items:
            let width = collectionView.bounds.width
            let numberOfItemsPerRow: CGFloat = 2
            let spacing: CGFloat = HomeCollectionViewController.sectionInsets.left
            let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
            let itemDimension = floor(availableWidth / numberOfItemsPerRow)
            // calculate the height of a sample one line text and then the height of the full text
            // let hOneLine = calculateLabelHeight(s: "bla", width: itemDimension)
            // let h = calculateLabelHeight(s: Items.allCases[indexPath.row].rawValue, width: itemDimension)
            // return CGSize(width: itemDimension, height: itemDimension - hOneLine + h)
            return CGSize(width: itemDimension, height: itemDimension)
        case .none:
            Log.log(level: .ERROR, "Invalid section in sizeFotItemAt")
            return CGSize.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        switch Section(rawValue: section) {
        case .header: return UIEdgeInsets.zero
        case .title: return UIEdgeInsets(top: 12.0, left: 0.0, bottom: 4.0, right: 0.0)
        case .items: return HomeCollectionViewController.sectionInsets
        case .none:
            Log.log(level: .ERROR, "Invalid section in insetForSectionAt")
            return UIEdgeInsets.zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        switch Section(rawValue: section) {
        case .header: return 0
        case .title: return 0
        case .items: return HomeCollectionViewController.sectionInsets.left
        case .none:
            Log.log(level: .ERROR, "Invalid section in minimumLineSpacing")
            return 0
        }
    }
}


class HomeHeaderCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var chatPicture: UIImageView!
    var tapClosure: (() -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        chatPicture.layer.cornerRadius = chatPicture.frame.width/2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tap.numberOfTapsRequired = 3
        picture.addGestureRecognizer(tap)
        picture.isUserInteractionEnabled = true
    }

    @objc func didTap() {
        tapClosure?()
    }

    func draw(imageURL: String) {
        picture.kf.setImage(with: URL(string: imageURL))
    }
}

class HomeTitleCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.backgroundColor = .offWhiteVeryLight
        contentView.backgroundColor = .offWhiteVeryLight
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func draw(title: String) {
        titleLabel.text = title
    }
}

class HomeItemsCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    let tempColors: [UIColor] = [.color1, .color2, .color3, UIColor.pastelBlue, .pastelCyan, UIColor.pastelRed, UIColor.pastelYellow, UIColor.pastelMagenta, ]

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .black
    }

    func draw(title: String, pictureName: String, color: UIColor) {
        titleLabel.text = title
        let border = -12.0
        picture.image = UIImage(named: pictureName)?.withAlignmentRectInsets(UIEdgeInsets(top: border, left: border, bottom: border, right: border))
        titleLabel.superview?.backgroundColor = color
        //picture.kf.setImage(with: URL(string: hotel.news[Int.random(in: 0...7)].imageFileURL))
        //picture.layer.cornerRadius = 10
    }
}

func calculateLabelHeight(s: String, width: CGFloat) -> CGFloat {
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = UIFont.preferredFont(forTextStyle: .title1)
    label.text = s
    label.sizeToFit()

    return label.frame.height
}
              
