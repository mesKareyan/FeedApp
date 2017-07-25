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
                     font: UIFont = UIFont .systemFont(ofSize: 23)) {
        var size = (text as NSString)
                    .size(attributes: [NSFontAttributeName : font])
        size.width  += 20
        size.height += 20
        self.init(frame: CGRect(origin: .zero, size: size))
        self.font = font
        self.text = text
        self.textAlignment = .center
    }
    
    func setup() {
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = bounds.height / 2
    }
    
}
