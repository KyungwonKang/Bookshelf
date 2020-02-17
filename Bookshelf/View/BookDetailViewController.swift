//
//  BookDetailViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var publishInfoLabel: UILabel!
    
    @IBOutlet weak var ratingsContainerView: UIView!
    
    private var lastTask: URLSessionDataTask?
    
    let book: Book
    init(book: Book) {
        self.book = book
        super.init(nibName: "BookDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateUI(book: book)
        self.loadBookDetailInfo(book: book)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.bookImageView.image = nil
        self.bookImageView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    private func updateUI(book: Book) {
        self.titleLabel.text = book.title
        self.subtitleLabel.text = book.subtitle
        if let imageurl = book.image, let url = URL(string: imageurl) {
            let task = URLSessionManager.getImageData(url: url) { [weak self] (result) in
                guard let self = self else { return }
                self.lastTask = nil
                
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.bookImageView.image = image
                        }
                    }
                case .failure(let error):
                    print("Get image data error: \(error.localizedDescription)")
                }
            }
            self.lastTask = task
        }
    }
    
    private func loadBookDetailInfo(book: Book) {
        guard let isbn13 = book.isbn13 else { return }
        let task = BookAPIManager.loadBookInfo(isbn13: isbn13, completion: { [weak self] (result) in
            guard let self = self else { return }
            self.lastTask = nil
            
            switch result {
            case .success(let detail):
                DispatchQueue.main.async {
                    self.updateUI(bookDetail: detail)
                }
            case .failure(let error):
                print("Load book detail error: \(error.localizedDescription)")
            }
        })
        
        self.lastTask = task
    }
    
    private func updateUI(bookDetail: BookDetail) {
        if let imageurl = bookDetail.image, let url = URL(string: imageurl) {
            let task = URLSessionManager.getImageData(url: url) { [weak self] (result) in
                guard let self = self else { return }
                self.lastTask = nil
                
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.bookImageView.image = image
                        }
                    }
                case .failure(let error):
                    print("Get image data error: \(error.localizedDescription)")
                }
            }
            self.lastTask = task
        }
        
        self.titleLabel.text = bookDetail.title
        self.subtitleLabel.text = bookDetail.subtitle
        self.publishInfoLabel.text = "\(bookDetail.authors ?? "") / \(bookDetail.publisher ?? "") / \(bookDetail.year ?? "")"
        if let ratingStr = bookDetail.rating, let rating = Int(ratingStr) {
            self.addRatingInfos(ratings: rating)
        }
    }
    
    private func addRatingInfos(ratings: Int) {
        self.ratingsContainerView.subviews.forEach { $0.removeFromSuperview() }
        var leading: CGFloat = 0
        let imageSize: CGFloat = 25
        let labelLeadingMargin: CGFloat = 5
        let maxRating: Int = 5
        // Add Images
        for i in 0..<maxRating {
            let systemImageName = (i < ratings) ? "star.fill" : "star"
            let starImageView = UIImageView(image: UIImage(systemName: systemImageName))
            starImageView.contentMode = .scaleAspectFit
            starImageView.translatesAutoresizingMaskIntoConstraints = false
            self.ratingsContainerView.addSubview(starImageView)
            
            let top = NSLayoutConstraint(item: starImageView, attribute: .top, relatedBy: .equal, toItem: self.ratingsContainerView, attribute: .top, multiplier: 1.0, constant: 0.0)
            let bottom = NSLayoutConstraint(item: starImageView, attribute: .bottom, relatedBy: .equal, toItem: self.ratingsContainerView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let lead = NSLayoutConstraint(item: starImageView, attribute: .leading, relatedBy: .equal, toItem: self.ratingsContainerView, attribute: .leading, multiplier: 1.0, constant: leading)
            let width = NSLayoutConstraint(item: starImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: imageSize)
 
            NSLayoutConstraint.activate([top, bottom, lead, width])
            leading += imageSize
        }
        
        // Add Label
        leading += labelLeadingMargin
        let ratingLabel = UILabel()
        self.ratingsContainerView.addSubview(ratingLabel)
        ratingLabel.text = "\(ratings)"
        ratingLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        let lead = NSLayoutConstraint(item: ratingLabel, attribute: .leading, relatedBy: .equal, toItem: self.ratingsContainerView, attribute: .leading, multiplier: 1.0, constant: leading)
        let centerY = NSLayoutConstraint(item: ratingLabel, attribute: .centerY, relatedBy: .equal, toItem: self.ratingsContainerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        NSLayoutConstraint.activate([lead, centerY])
    }
}
