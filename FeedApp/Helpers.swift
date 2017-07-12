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
    
}


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
