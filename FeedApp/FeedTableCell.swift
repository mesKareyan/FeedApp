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
    
    @IBOutlet weak var tagsContainerView: UIView!
    @IBOutlet weak var tagsContainerHeightConstraint: NSLayoutConstraint!
    
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
        // add tag views
        addTagViews()
    }
    
    func addTagViews() {
        
        let inset: CGFloat = 20.0
        var xPosition:CGFloat = inset
        var yPosition:CGFloat = inset
    
        var tagsContainerHeightConstant:CGFloat = 0
        var colomnCount = 0
        
        for index in 0..<5 {
            var text = "bla "
            for _ in 0..<index {
                text += "bla "
            }
            let tagView = TagLabel(text: text)
            tagsContainerView.addSubview(tagView)
            tagView.frame.origin = CGPoint(x: xPosition, y: yPosition)
            //shift with label width
            xPosition += tagView.bounds.width + inset
            //add new line
            if tagsContainerView.frame.width - xPosition < tagView.bounds.width + inset {
                xPosition = inset
                yPosition += tagView.bounds.height + inset
                colomnCount += 1
                tagsContainerHeightConstant = yPosition + inset
            }
        }
        tagsContainerHeightConstant -= inset
        tagsContainerHeightConstraint.constant = tagsContainerHeightConstant
        layoutIfNeeded()
    }
    
}

