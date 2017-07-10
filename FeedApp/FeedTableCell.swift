//
//  FeedTableCell.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var unreadCircleView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //unreadCircleView.layer.cornerRadius = unreadCircleView.frame.width / 2.0;
    }
    
    func configure(for newsEntity: NewsItemEntity) {
    }
    
    
}

