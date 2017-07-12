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
    
    func configure(for newsEntity: NewsFeedEntity) {
        
        topLabel.text      = newsEntity.category
        detailsLabel.text  = newsEntity.title
        dateLabel.text     = newsEntity.date?.shortString
        unreadCircleView.isHidden = newsEntity.isRead
        
        if let urlString = newsEntity.thumbnail,
            !urlString.isEmpty
        {
            let url = URL(string: urlString)!
            thumbnailImageView.hnk_setImageFromURL(url, placeholder: #imageLiteral(resourceName: "empty"))
        }
    }
    
    
}

