//
//  TagView.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/25/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

class TagLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience init(text: String,
                     maxLength: CGFloat,
                     font: UIFont = UIFont.systemFont(ofSize: 21)) {
        var size = (text as NSString)
                    .size(attributes: [NSFontAttributeName : font])
        size.width  += 16
        size.height += 16
        self.init(frame: CGRect(origin: .zero, size: size))
        if size.width > maxLength {
            size.width = maxLength - 16
            self.adjustsFontSizeToFitWidth = true
            self.bounds.size = size
        }
        self.font = font
        self.text = text
        self.textAlignment = .center
    }
    
    func setup() {
        backgroundColor = UIColor.groupTableViewBackground
        textColor = UIColor.lightGray
        clipsToBounds = true
        layer.cornerRadius = min(bounds.height / 2, bounds.width / 2)
    }
    
}
