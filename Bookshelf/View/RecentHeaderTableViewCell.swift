//
//  RecentHeaderTableViewCell.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

protocol RecentClearDelegate: NSObjectProtocol {
    func clearButtonClicked()
}

class RecentHeaderTableViewCell: UITableViewCell {

    weak var delegate: RecentClearDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clearButtonClicked(_ sender: UIButton) {
        self.delegate?.clearButtonClicked()
    }
}
