//
//  BookDetailHeaderTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/21.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookDetailInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var ratingsContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var publishInfoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var linkTextView: UITextView!
    
    private var lastTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.bookImageView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bookImageView.layer.shadowOpacity = 1.0
        self.bookImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.lastTask?.cancel()
        self.lastTask = nil
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(book: Book) {
        self.titleLabel.text = book.title
        self.subtitleLabel.text = book.subtitle
        self.priceLabel.text = book.price
        self.linkTextView.text = book.url
        
        let bookImage = BookCacheManager.shared.images.object(forKey: (book.image ?? "") as NSString)
        self.bookImageView.image = bookImage
    }
    
    func configure(bookDetail: BookDetail) {
        self.titleLabel.text = bookDetail.title
        self.subtitleLabel.text = bookDetail.subtitle
        self.publishInfoLabel.text = "\(bookDetail.authors ?? "") / \(bookDetail.publisher ?? "") / \(bookDetail.year ?? "")"
        self.descriptionLabel.text = bookDetail.desc
        self.priceLabel.text = bookDetail.price
        self.linkTextView.text = bookDetail.url
        
        if let ratingStr = bookDetail.rating, let rating = Int(ratingStr) {
            self.addRatingInfos(ratings: rating)
        }
        if let imagePath = bookDetail.image {
            if let bookImage = BookCacheManager.shared.images.object(forKey: imagePath as NSString) {
                self.bookImageView.image = bookImage
            } else if let url = URL(string: imagePath) {
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
