//
//  FeedCollectionCell.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/11/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import Haneke

class FeedCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var newsItem: NewsFeedEntity!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showCloseButton))
        addGestureRecognizer(longPress)
    }
    
    func showCloseButton() {
        
        closeButton.isHidden = false
        
        UIView.animate(
            
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0.6,
            options:  .allowUserInteraction,
            animations: {
                
                self.closeButton.transform = CGAffineTransform.identity
                
        },  completion: { finished in
            
        })
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = 10.0
        containerView.layer.borderWidth = 4.0
        containerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        containerView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.groupTableViewBackground.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 1.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: self.containerView.frame, cornerRadius: self.containerView.layer.cornerRadius).cgPath
    }
    
    @IBAction func closeButtonTaped(_ sender: UIButton) {
       self.newsItem.isPinned = false
        CoreDataManager.shared.saveContext()
        Shared.imageCache.removeAll()
    }
    
    func configure(for newsEntity: NewsFeedEntity) {
        newsItem = newsEntity
        detailsLabel.text  = newsEntity.title
        if let urlString = newsEntity.thumbnail,
            !urlString.isEmpty
        {
            let url = URL(string: urlString)!
            thumbnailImageView.hnk_setImageFromURL(url, placeholder: #imageLiteral(resourceName: "empty"))
        }
    }
    
}
