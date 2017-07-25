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
    var news: NewsFeedEntity!
    
    func configure(for newsEntity: NewsFeedEntity) {
        
        news = newsEntity
        topLabel.text      = newsEntity.category
        detailsLabel.text  = newsEntity.title
        dateLabel.text     = newsEntity.date?.shortString
        unreadCircleView.isHidden = newsEntity.isRead
        tagsContainerView.backgroundColor = UIColor.white
        
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
        
        tagsContainerView.subviews.forEach { subview in subview.removeFromSuperview() }
        guard let text = news.title else { return }
        
        let words = (text as NSString).getTokens()
        
        let inset: CGFloat = 8
        var xPosition:CGFloat = inset
        var yPosition:CGFloat = inset
    
        var tagsContainerHeightConstant:CGFloat = 0
        var colomnCount = 0
        
        for word in words {
            let tagView = TagLabel(text: word)
            tagsContainerView.addSubview(tagView)
            tagView.frame.origin = CGPoint(x: xPosition, y: yPosition)
            //shift with label width
            xPosition += tagView.bounds.width + inset
            //add new line
            if tagsContainerView.frame.width - xPosition < tagView.bounds.width + 2 * inset {
                xPosition = inset
                yPosition += tagView.bounds.height + inset
                colomnCount += 1
                tagsContainerHeightConstant = yPosition + 2 * inset
            }
            tagsContainerHeightConstant +=  2 * inset
        }
        tagsContainerHeightConstant +=  inset
        tagsContainerHeightConstraint.constant = tagsContainerHeightConstant
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

