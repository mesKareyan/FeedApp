//  FeedTableCell.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

typealias TagViewsDict = [String : TagViewsWrapper]

class TagViewsWrapper: NSObject {
    var views = [TagLabel]()
    var height: CGFloat = 0
    
    init(views: [TagLabel], height: CGFloat) {
        super.init()
        self.views = views
        self.height = height
    }
}

class FeedTableCell: UITableViewCell {
    
    @IBOutlet weak var unreadCircleView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var tagsContainerView: UIView!
    @IBOutlet weak var tagsContainerHeightConstraint: NSLayoutConstraint!
    
    var news: NewsFeedItemRealm! {
        didSet {
            self.configure(for: news)
        }
    }
    var imageURLSting: String!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailImageView.sd_setShowActivityIndicatorView(true)
        thumbnailImageView.sd_setIndicatorStyle(.gray)
        tagsContainerView.backgroundColor = UIColor.white
        unreadCircleView.tintColor = .appColor
    }
    
    func configure(for newsEntity: NewsFeedItemRealm) {
        
        topLabel.text      = newsEntity.category
        detailsLabel.text  = newsEntity.title
        dateLabel.text     = newsEntity.date?.shortString
        unreadCircleView.isHidden = newsEntity.read
        imageURLSting   = newsEntity.thumbnailURL
        
        if let urlString = newsEntity.thumbnailURL,
            !urlString.isEmpty
        {
            let url = URL(string: urlString)!
            thumbnailImageView.sd_setImage(with: url)
        }
        // add tag views
        configureTagViews(forWidth: tagsContainerView.bounds.width)
    }

    //MARK: - Tag views
    func configureTagViews(forWidth containerWidth: CGFloat) {
        
        //updateTag views
        tagsContainerView.subviews.forEach { subview in subview.removeFromSuperview()
        }
        
        //get Tokens from cache or create
        guard let text = news?.title else { return }
        
        var words: [NSString]! = tokensCache.object(forKey: text as NSString) as? [NSString]
        if words == nil {
            words = text.getTokens() as [NSString]
            tokensCache.setObject(words! as NSArray, forKey: text as NSString)
        }
        
        var tagViewsWrapper: TagViewsWrapper! = tagViewsCache.object(forKey: text as NSString)
        if  tagViewsWrapper != nil {
            for tagView in tagViewsWrapper.views {
                tagsContainerView.addSubview(tagView)
            }
             tagsContainerHeightConstraint.constant = tagViewsWrapper.height
            return
        }
        
        var tagViews = [TagLabel]()

        let inset: CGFloat = 8
        var xPosition:CGFloat = inset
        var yPosition:CGFloat = inset
    
        var tagsContainerHeightConstant:CGFloat =  inset
        var colomnCount = 0
        
        var tagViewFromPrev: TagLabel!

        for (index, currentWord) in words.enumerated() {
            
            var currentTagView : TagLabel! = tagViewFromPrev
            if currentTagView == nil {
                currentTagView = TagLabel(text: currentWord as String, maxLength: bounds.width)
            }
            // let currentTagView = TagLabel(text: currentWord)
            currentTagView.frame.origin = CGPoint(x: xPosition, y: yPosition)
            tagViews.append(currentTagView)
            
            if index == 0 {
                tagsContainerHeightConstant += currentTagView.bounds.height
            }
            
            guard  index < words.count - 1  else {
                break
            }
            
            let nextWord    =  words[index + 1]
            let nextTagView = TagLabel(text: nextWord as String, maxLength: bounds.width)
            tagViewFromPrev  = nextTagView
            //calculate next tavView frame
            //shift with label width
            xPosition += currentTagView.bounds.width + inset
            //add new line
            if xPosition + nextTagView.bounds.width + inset >  containerWidth {
                xPosition = inset
                yPosition += currentTagView.bounds.height + inset
                colomnCount += 1
                tagsContainerHeightConstant = yPosition + nextTagView.bounds.height
            }
        }
        
        let tagsViewHeight = tagsContainerHeightConstant + inset
        tagsContainerHeightConstraint.constant = tagsViewHeight
        tagViewsWrapper = TagViewsWrapper(views: tagViews, height: tagsViewHeight)
        tagViewsCache.setObject(tagViewsWrapper, forKey: text as NSString)
        
    }
}


