//
//  Helpers.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

extension Date {
    
    var  shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
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
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate,
                                   .withTime,
                                   .withDashSeparatorInDate,
                                   .withColonSeparatorInTime]
        let dateObj = formatter.date(from: self)
        return dateObj
    }
    
    var shortNSDate: NSDate? {
        return self.shortDate as NSDate?
    }
    
    var dateTimeInterval: TimeInterval? {
        return self.shortDate?.timeIntervalSince1970
    }
    
}

extension TimeInterval {
    
    var date: Date {
        return Date(timeIntervalSince1970: self)
    }
    
}

extension UIColor {

    static var appRed: UIColor {
        return UIColor(red: 255.0 / 255.0, green: 51.0/255.0, blue: 52/255.0, alpha: 1.0)
    }
    
}

