//
//  InfoViewController.swift
//  Test2
//
//  Created by maciulek on 13/06/2021.
//

import UIKit

class InfoDetailViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!

    var reviewsManager = ReviewsManager()
    //var infoItem:InfoItem = initInfoItems()
    var infoItem:InfoItem = InfoItem()
    var blurEffectView: UIView = UIView()

    enum Section {
        case all
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        //reviewsManager.delegate = self
        reviewsManager.start(group: "info", id: infoItem.id ?? "")

        subtitleLabel.text = infoItem._subtitle
        textLabel.text = infoItem._text
        subtitleLabel.textColor = .black
        textLabel.textColor = .black

        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        if #available(iOS 13.0, *) {
            backgroundImageView.blur(withStyle: .systemChromeMaterialLight)
        } else {
            backgroundImageView.blur(withStyle: .prominent)
        }

        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self

        pageControl.numberOfPages = infoItem.images.count
        pageControl.isHidden = infoItem.images.count <= 1
    }

    deinit {
        reviewsManager.stop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar(collectionView: collectionView, tintColor: .black)
        navigationController?.navigationBar.prefersLargeTitles = false
        title = infoItem._title
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }

    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(1.0))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }

    @IBAction func newButtonPressed(_ sender: Any) {
        if let vc = self.prepareModal(storyBoard: "Activities", id: "RateReview") as? RateReviewViewController {
            vc.group = "info"
            vc.id = infoItem.id
            vc.reviewTitle = infoItem.title
            vc.reviewedImage = UIImage(named: "JaNaPlaya")
            present(vc, animated: true)
        }
    }
}

extension InfoDetailViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoItem.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! InfoPictureCell
        cell.draw(infoItem: infoItem, pictureNumber: indexPath.row)
        return cell
    }
}
/*
extension InfoDetailViewController: ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .right)
            self.tableView.endUpdates()
        }
    }
    
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .fade)
            self.tableView.endUpdates()
        }
    }
}
*/


class InfoPictureCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        imageTextLabel.layer.cornerRadius = 10
        imageTextLabel.layer.masksToBounds = true
    }

    func draw(infoItem: InfoItem, pictureNumber: Int) {
        layer.cornerRadius = 10.0
        imageView.kf.setImage(with: URL(string: infoItem.images[pictureNumber].url))
        imageTextLabel.text = infoItem._imageText(i: pictureNumber)
    }
}

