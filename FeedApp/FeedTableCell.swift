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
    
    var news: NewsFeedItemRealm!
    var imageURLSting: String!
    
    func configure(for newsEntity: NewsFeedItemRealm) {
        
        news = newsEntity
        topLabel.text      = newsEntity.category
        detailsLabel.text  = newsEntity.title
        dateLabel.text     = newsEntity.date?.shortString
        //unreadCircleView.isHidden = newsEntity.isRead!
        tagsContainerView.backgroundColor = UIColor.white
        imageURLSting   = newsEntity.thumbnail
        if let urlString = newsEntity.thumbnail,
            !urlString.isEmpty
        {
            let url = URL(string: urlString)!
            thumbnailImageView.hnk_setImageFromURL(url, placeholder: #imageLiteral(resourceName: "empty"))
        }
        // add tag views
        configureTagViews(forWidth: tagsContainerView.bounds.width)
    }
    
    //MARK: - Tag views
    func configureTagViews(forWidth containerWidth: CGFloat) {
        
        tagsContainerView.subviews.forEach { subview in subview.removeFromSuperview()
        }
        
        guard let text = news.title else { return }
        
        let words = (text as NSString).getTokens()
        
        let inset: CGFloat = 8
        var xPosition:CGFloat = inset
        var yPosition:CGFloat = inset
    
        var tagsContainerHeightConstant:CGFloat =  inset
        var colomnCount = 0
        
        for (index, currentWord) in words.enumerated() {
            
            let currentTagView = TagLabel(text: currentWord)
            currentTagView.frame.origin = CGPoint(x: xPosition, y: yPosition)
            tagsContainerView.addSubview(currentTagView)
            
            if index == 0 {
                tagsContainerHeightConstant += currentTagView.bounds.height
            }
            
            guard  index < words.count - 1  else {
                break
            }
            
            let nextWord    =  words[index + 1]
            let nextTagView = TagLabel(text: nextWord)
            
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
        tagsContainerHeightConstraint.constant = tagsContainerHeightConstant + inset
        layoutIfNeeded()
    }
}

extension NSString {
    
    func getTokens() -> [String] {
        var tokens = [String]()
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames, .omitOther]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en")
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = self as String
        tagger.enumerateTags(in: NSMakeRange(0, self.length), scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            let token = self.substring(with: tokenRange)
            if !["Preposition", "Particle", "Determiner", "Verb", "Adverb", "Pronoun"].contains(tag)  {
                if token != "|" {
                 tokens.append(token)
                }
            }
        }
        return tokens
    }
    
}

