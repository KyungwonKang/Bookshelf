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
    
    private var imageTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.bookImageView.layer.shadowColor = UIColor.lightGray.cgColor
        self.bookImageView.layer.shadowOpacity = 1.0
        self.bookImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageTask?.cancel()
        self.imageTask = nil
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setBaseInfo(_ book: Book) {
        self.titleLabel.text = book.title
        self.subtitleLabel.text = book.subtitle
        self.priceLabel.text = book.price
        self.linkTextView.text = book.url
        
        let cache = BookImageManager.shared.getCache(forURL: book.image ?? "")
        self.bookImageView.image = cache
    }
    
    func setDetailInfo(_ detail: BookDetail) {
        self.publishInfoLabel.text = "\(detail.authors ?? "") / \(detail.publisher ?? "") / \(detail.year ?? "")"
        self.descriptionLabel.text = detail.desc
        
        if let ratingStr = detail.rating, let rating = Int(ratingStr) {
            self.addRatingInfos(ratings: rating)
        }
        
        if let imagePath = detail.image {
            if let cache = BookImageManager.shared.getCache(forURL: imagePath) {
                self.bookImageView.image = cache
            } else {
                self.imageTask = BookImageManager.shared.loadImage(fromURL: imagePath, completion: { [weak self] (image) in
                    guard let self = self else { return }
                    self.imageTask = nil
                    DispatchQueue.main.async {
                        self.bookImageView.image = image
                    }
                })
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
