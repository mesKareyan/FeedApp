//
//  Helpers.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation

extension Date {
    
    var  shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
        return dateFormatter.string(from: self)
    }
    
}

extension NSDate {
    
    var  shortString: String {
        let date = self as Date
        return date.shortString
    }
    
}

extension String {
    
    var shortDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
        dateFormatter.locale = Locale(identifier: "en_GB")
        let dateObj = dateFormatter.date(from: self)
        return dateObj
    }
    
    var shortNSDate: NSDate? {
        return self.shortDate as NSDate?
    }
    
}
