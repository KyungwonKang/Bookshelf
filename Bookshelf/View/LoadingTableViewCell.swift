//
//  LoadingTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/19.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startAnimating() {
        self.indicatorView.startAnimating()
    }
    
    func stopAnimating() {
        self.indicatorView.stopAnimating()
    }
}
