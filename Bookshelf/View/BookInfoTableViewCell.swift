//
//  BookInfoTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var isbnLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bookImageView.image = nil
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
        self.priceLabel.text = nil
        self.isbnLabel.text = nil
        self.urlLabel.text = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bookImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(book: Book) {
        self.titleLabel.text = book.title
        self.subtitleLabel.text = book.subtitle
        self.priceLabel.text = book.price
        self.isbnLabel.text = "ISBN13: \(book.isbn13 ?? "")"
        self.urlLabel.text = book.url
        
        if let imageurl = book.image, let url = URL(string: imageurl) {
            URLSessionManager.getImageData(url: url) { [weak self] (data) in
                guard let self = self else { return }
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.bookImageView.image = image
                    }
                }
            }
        }
    }
}
