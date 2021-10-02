//
//  InfoViewController.swift
//  Test2
//
//  Created by maciulek on 13/06/2021.
//

import UIKit

class InfoViewController: UIViewController, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!

    var infoItem:InfoItem = InfoItem()
    var blurEffectView: UIView = UIView()

    enum Section {
        case all
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        titleLabel.text = infoItem.title
        subtitleLabel.text = infoItem.subtitle
        textLabel.text = infoItem.text
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: "cloud")
        backgroundImageView.blur(withStyle: .dark)
/*
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        backgroundImageView.addSubview(blurEffectView)
*/
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.contentInsetAdjustmentBehavior = .never
        
        collectionView.delegate = self
        if infoItem.images.count <= 1 {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
        }

        //navigationController?.navigationBar.barStyle = UIBarStyle.black
        //navigationController?.navigationBar.tintColor = UIColor.yellow
        //navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.orange]
        //navigationController?.navigationBar.barTintColor = .red
}

/*  // not needed after setting blurEffectView.frame = backgroundImageView.bounds (not view.bounds)
    // resize blurEffectView after rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.blurEffectView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        }
    }
*/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white

        navigationController?.hidesBarsOnSwipe = false
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

}


extension InfoViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoItem.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! InfoPictureCell
        cell.backgroundColor = .black
        cell.draw(infoItem: infoItem, pictureNumber: indexPath.row)
        return cell
    }
}

class InfoPictureCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageTextLabel: UILabel!
    let bgColor: UIColor = .lightGray

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = bgColor
        contentView.backgroundColor = bgColor
        imageTextLabel.backgroundColor = bgColor
    }

    func draw(infoItem: InfoItem, pictureNumber: Int) {
        layer.cornerRadius = 10.0
        imageView.image = nil
        imageView.image = UIImage(named: infoItem.images[pictureNumber].url) // TODO remove
//        if let url = URL(string: infoItem.imageFileURLs[pictureNumber]) {
//            imageView.kf.setImage(with: url)
//        }
        imageTextLabel.text = infoItem.images[pictureNumber].text
    }
}
