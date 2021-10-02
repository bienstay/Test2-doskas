//
//  NewsDetailViewController.swift
//  Test2
//
//  Created by maciulek on 11/06/2021.
//

import UIKit

class NewsDetailViewController: UIViewController {

    var post = NewsPost()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: NewsDetailHeaderView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.contentInsetAdjustmentBehavior = .never   // hides the navigationbar
        tableView.delegate = self
        tableView.dataSource = self

        headerView.draw(post: post)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLongPress))
        //tap.minimumPressDuration = 1
        tap.numberOfTapsRequired = 1
        headerView.titleLabel.isUserInteractionEnabled = true
        headerView.titleLabel.addGestureRecognizer(tap)
        headerView.addGestureRecognizer(tap)
        headerView.headerDimmedView.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        
        deleteBarButton.title = guest.isAdmin() ? "Delete" : ""
        deleteBarButton.isEnabled = guest.isAdmin()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func deleteBarButtonPressed(_ sender: UIBarButtonItem) {
        let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertController.Style.alert)
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteCurrentPost()
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
        
    func deleteCurrentPost() {
        let errStr = FireB.shared.removeRecord(key: post.postId, record: post) { record in
            if record == nil {
                showInfoDialogBox(vc: self, title: "Error", message: "Post delete failed")
            } else {
                showInfoDialogBox(vc: self, title: "Info", message: "Post deleted") {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        if errStr != nil { print(errStr!) }
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer?) {
        print("Long press detected")
    }
}

extension NewsDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsDetailHeaderCell.self), for: indexPath) as! NewsDetailHeaderCell
            cell.longTapClosure = {
                let vc = self.createViewController(storyBoard: "News", id: "NewPost") as! NewNewsPostViewController
                vc.postToEdit = self.post
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.draw(post: post)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsDetailTextCell.self), for: indexPath) as! NewsDetailTextCell
            cell.draw(post: post)
            return cell
        default:
            return UITableViewCell()
        }
    }
}


class NewsDetailHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerDimmedView: UIView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    func draw(post: NewsPost) {
        titleLabel.text = post.title
        subtitleLabel.text = post.subtitle
        if let url = URL(string: post.imageFileURL) {
            headerImageView.isHidden = false
            headerDimmedView.isHidden = false
            headerImageView.kf.setImage(with: url)
        } else {
            //headerImageView.isHidden = true
            //headerDimmedView.isHidden = true
            headerImageView.image = UIImage(named: "Lukasz")
        }
        //displayHeart()
    }
}

class NewsDetailTextCell: UITableViewCell {

    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func draw(post: NewsPost) {
        timestampLabel.text = post.timestamp.formatFriendly()
        postTextLabel.text = post.text
    }
}

class NewsDetailHeaderCell: UITableViewCell {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerDimmedView: UIView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    var longTapClosure: () -> () = {}

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tap.minimumPressDuration = 1
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
    }

    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer?) {
        if let s = sender, s.state == .began {
            longTapClosure()
        }
    }

    func draw(post: NewsPost) {
        titleLabel.text = post.title
        subtitleLabel.text = post.subtitle
        if let url = URL(string: post.imageFileURL) {
            headerImageView.isHidden = false
            headerDimmedView.isHidden = false
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.kf.setImage(with: url)
        } else {
            //headerImageView.isHidden = true
            //headerDimmedView.isHidden = true
            headerImageView.contentMode = .scaleAspectFit
            headerImageView.image = UIImage(named: "Lukasz")
        }
        //displayHeart()
    }
}

