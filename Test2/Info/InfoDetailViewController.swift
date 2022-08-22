//
//  InfoViewController.swift
//  Test2
//
//  Created by maciulek on 13/06/2021.
//

import UIKit

class InfoDetailViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reviewButton: UIButton!

    var reviewsManager = ReviewsManager()
    var infoItem:InfoItem = InfoItem()
    var blurEffectView: UIView = UIView()
    var currentPage = 0

    enum Sections: Int, CaseIterable {
        case image
        case text
        case review
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(collectionView: collectionView)
        reviewsManager.delegate = self
        reviewsManager.start(group: "info", id: infoItem.id ?? "")

        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        if #available(iOS 13.0, *) {
            backgroundImageView.blur(withStyle: .systemChromeMaterialLight)
        } else {
            backgroundImageView.blur(withStyle: .prominent)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = UIColor.clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UINib(nibName: "ReviewCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ReviewCell")
        collectionView.register(UINib(nibName: "ReviewCollectionViewHeader", bundle: nil), forSupplementaryViewOfKind: "review-header-kind", withReuseIdentifier: "ReviewHeader")
    }

    deinit {
        reviewsManager.stop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            setupTransparentNavigationBar(collectionView: collectionView, tintColor: .label)
        }
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = infoItem._title
        reviewButton.isHidden = phoneUser.isStaff
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentPage = indexPath.row
        if let footer = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: 0)) as? InfoPictureFooter {
            footer.draw(currentPage: currentPage, nrOfPages: infoItem.images.count)
        }
    }

    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] (section: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            switch Sections(rawValue: section) {
            case .image:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalHeight(0.5))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging

                let footerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerSize, elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
                section.boundarySupplementaryItems = [sectionFooter]
/*
                section.visibleItemsInvalidationHandler = { [weak self] (items, offset, env) -> Void in
                    guard let self = self else { return }

                    let page = round(offset.x / self.view.bounds.width)
                    print("--------------- \(page)")
                    self.currentPage = Int(page)

                    //self.pagingInfoSubject.send(PagingInfo(sectionIndex: sectionIndex, currentPage: Int(page)))
                }
*/
                return section
            case .text:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension:  .estimated(10.0))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)

                return section
            case .review:
                return self?.reviewsManager.reviews.isEmpty ?? true ? nil : ReviewCollectionViewCell.createLayoutSection()
            default:
                return nil
            }
        }
        
        return layout
    }

    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if let vc = self.prepareModal(storyBoard: "Reviews", id: "RateReview") as? RateReviewViewController {
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
        collectionView.layoutIfNeeded()
        return Sections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .image: return infoItem.images.count
        case .text: return 1
        case .review: return reviewsManager.reviews.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .image:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! InfoPictureCell
            cell.draw(infoItem: infoItem, pictureNumber: indexPath.row)
            return cell
        case .text:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "infoCell", for: indexPath) as! InfoTextCell
            cell.draw(infoItem: infoItem)
            return cell
        case .review:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReviewCell", for: indexPath) as! ReviewCollectionViewCell
            let r = reviewsManager.reviews[indexPath.row]
            cell.draw(timestamp: r.timestamp, rating: r.rating, review: r.review, roomNumber: r.roomNumber, translation: reviewsManager.translations[r.id ?? ""])
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case "review-header-kind":
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReviewHeader", for: indexPath)// as? HeaderSupplementaryView
            //headerView.isHidden = reviewsManager.reviews.isEmpty
            return headerView
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "InfoSectionHeader", for: indexPath)// as? HeaderSupplementaryView
            return headerView
        case UICollectionView.elementKindSectionFooter:
            if let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "InfoSectionFooter", for: indexPath) as? InfoPictureFooter {
                footerView.draw(currentPage: currentPage, nrOfPages: infoItem.images.count)
                return footerView
            }
        default:
            break
        }
        return UICollectionReusableView()
    }

    // try to avoid a crash on iPhoneX
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
}

extension InfoDetailViewController: ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            //self.collectionView.reloadSections([Sections.review.rawValue])
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            //self.collectionView.reloadSections([Sections.review.rawValue])
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}


class InfoPictureFooter: UICollectionReusableView {
    @IBOutlet private weak var pageControl: UIPageControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        pageControl.currentPage = 0
    }
    
    func draw(currentPage: Int, nrOfPages: Int) {
        pageControl.numberOfPages = nrOfPages
        pageControl.isHidden = nrOfPages <= 1
        pageControl.currentPage = currentPage
    }
}

class InfoPictureCell: ShadedCollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true
    }

    func draw(infoItem: InfoItem, pictureNumber: Int) {
        imageView.kf.setImage(with: URL(string: infoItem.images[pictureNumber].url))
        imageTextLabel.text = infoItem._imageText(i: pictureNumber)
    }
}

class InfoTextCell: UICollectionViewCell {
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var reviewTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func draw(infoItem: InfoItem) {
        subtitleLabel.text = infoItem._subtitle
        reviewTextLabel.text = infoItem._text
    }
}

