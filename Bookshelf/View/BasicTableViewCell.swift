//
//  BasicTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BasicTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String) {
        self.titleLabel.text = title
    }
}
