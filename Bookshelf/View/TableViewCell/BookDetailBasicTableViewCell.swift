//
//  BookDetailTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/21.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookDetailBasicTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(title: String, value: String) {
        self.titleLabel.text = title
        self.valueLabel.text = value
    }
}
